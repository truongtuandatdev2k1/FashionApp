package services

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	payos "github.com/payOSHQ/payos-lib-golang/v2"

	"myfashion/internal/common/config"
	"myfashion/internal/modules/payment/entities"
	"myfashion/internal/modules/payment/repositories"
)

type PayOSService struct {
	cfg        config.Config
	client     *payos.PayOS
	payRepo    *repositories.PaymentRepository
	orderRepo  *repositories.OrderAdapter
	expireMins int
}

func NewPayOSService(cfg config.Config, payRepo *repositories.PaymentRepository, orderRepo *repositories.OrderAdapter) (*PayOSService, error) {
	client, err := payos.NewPayOS(&payos.PayOSOptions{
		ClientId:    cfg.PayOSClientID,
		ApiKey:      cfg.PayOSAPIKey,
		ChecksumKey: cfg.PayOSChecksumKey,
	})
	if err != nil {
		return nil, err
	}
	exp := cfg.PaymentExpireMinutes
	if exp <= 0 {
		exp = 10
	}
	return &PayOSService{cfg: cfg, client: client, payRepo: payRepo, orderRepo: orderRepo, expireMins: exp}, nil
}

func (s *PayOSService) CreatePaymentLinkForOrder(ctx context.Context, orderUUID repositories.OrderModel) (*repositories.PaymentModel, *payos.CreatePaymentLinkResponse, error) {
	amount := int(orderUUID.FinalAmount)
	if amount <= 0 {
		return nil, nil, entities.ErrInvalidOrder
	}

	// If payment already exists, return existing checkout url
	if existing, err := s.payRepo.FindByOrderID(ctx, orderUUID.ID); err == nil && existing != nil {
		if existing.CheckoutURL != "" {
			return existing, &payos.CreatePaymentLinkResponse{CheckoutUrl: existing.CheckoutURL, PaymentLinkId: existing.PayosPaymentLinkID, OrderCode: int64(existing.PayosOrderCode)}, nil
		}
	}

	item := payos.PaymentLinkItem{
		Name:     fmt.Sprintf("Order %s", orderUUID.OrderNumber),
		Quantity: 1,
		Price:    amount,
	}

	expiredAt := int(time.Now().Add(time.Duration(s.expireMins) * time.Minute).Unix())
	req := payos.CreatePaymentLinkRequest{
		OrderCode:   int64(orderUUID.OrderCode),
		Amount:      amount,
		Description: fmt.Sprintf("DH %s", orderUUID.OrderNumber),
		Items:       []payos.PaymentLinkItem{item},
		CancelUrl:   s.cfg.PayOSCancelURL,
		ReturnUrl:   s.cfg.PayOSReturnURL,
		ExpiredAt:   &expiredAt,
	}

	pl, err := s.client.PaymentRequests.Create(ctx, req)
	if err != nil {
		return nil, nil, err
	}

	m := &repositories.PaymentModel{
		OrderID:            orderUUID.ID,
		Provider:           "payos",
		Amount:             amount,
		Status:             string(entities.StatusPending),
		PayosOrderCode:     orderUUID.OrderCode,
		PayosPaymentLinkID: pl.PaymentLinkId,
		CheckoutURL:        pl.CheckoutUrl,
	}
	if err := s.payRepo.Create(ctx, m); err != nil {
		return nil, nil, err
	}
	return m, pl, nil
}

func (s *PayOSService) GetPaymentByOrderID(ctx context.Context, orderID repositories.OrderModel) (*repositories.PaymentModel, error) {
	return s.payRepo.FindByOrderID(ctx, orderID.ID)
}

func (s *PayOSService) HandleWebhook(ctx context.Context, raw map[string]any) error {
	verifiedData, err := s.client.Webhooks.VerifyData(ctx, raw)
	if err != nil {
		return fmt.Errorf("payos webhook verification failed: %w", err)
	}

	// The verified data is also a map, we need to parse it into our expected struct.
	var webhookData payos.WebhookData
	jsonData, err := json.Marshal(verifiedData)
	if err != nil {
		return fmt.Errorf("failed to marshal verified webhook data: %w", err)
	}
	if err := json.Unmarshal(jsonData, &webhookData); err != nil {
		return fmt.Errorf("failed to unmarshal verified webhook data: %w", err)
	}

	orderCode := uint64(webhookData.OrderCode)
	if orderCode == 0 {
		return entities.ErrInvalidWebhook
	}

	pay, err := s.payRepo.FindByPayosOrderCode(ctx, orderCode)
	if err != nil {
		return err // Could be gorm.ErrRecordNotFound, handled by caller
	}

	// Idempotency check
	if pay.Status == string(entities.StatusPaid) {
		return nil
	}

	// Store raw webhook for auditing
	pay.RawWebhook = string(jsonData)

	// PayOS success code is "00". Any other code indicates a non-successful payment.
	if webhookData.Code != "00" {
		pay.Status = string(entities.StatusFailed)
		return s.payRepo.Update(ctx, pay)
	}

	// Payment is successful, update status for payment and order
	pay.Status = string(entities.StatusPaid)
	if err := s.payRepo.Update(ctx, pay); err != nil {
		return err
	}

	return s.orderRepo.SetPaidAndConfirm(ctx, pay.OrderID)
}
