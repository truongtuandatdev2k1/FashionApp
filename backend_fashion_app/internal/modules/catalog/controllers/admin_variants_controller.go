package controllers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"

	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/catalog/api"
	"myfashion/internal/modules/catalog/repositories"
)

// @Summary (Admin) List product variants
// @Description (Shop/Admin) Lấy danh sách biến thể theo product.
// @Security Bearer
// @Tags Products
// @Produce json
// @Param id path int true "Product ID"
// @Success 200 {object} resp.Envelope{data=api.AdminVariantListResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/products/{id}/variants [get]
func (c *CatalogController) AdminListVariants(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	productID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	// Ensure product exists
	if _, err := c.productSvc.GetProduct(r.Context(), productID); err != nil {
		resp.Error(w, http.StatusNotFound, "product not found")
		return
	}

	var rows []repositories.ProductVariantModel
	if err := c.db.WithContext(r.Context()).Preload("ProductColor").Where("product_id = ?", productID).Order("id DESC").Find(&rows).Error; err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to list variants")
		return
	}

	items := make([]api.AdminVariantResponse, 0, len(rows))
	for _, v := range rows {
		items = append(items, api.AdminVariantResponse{
			VariantID:      v.ID,
			ProductID:      v.ProductID,
			ProductColorID: v.ProductColorID,
			ColorHex:       v.ProductColor.ColorHex,
			ColorName:      v.ProductColor.ColorName,
			SizeCode:       v.SizeCode,
			Stock:          v.Stock,
			Sku:            v.Sku,
			CreatedAt:      v.CreatedAt,
			UpdatedAt:      v.UpdatedAt,
		})
	}

	resp.OK(w, api.AdminVariantListResponse{Items: items})
}

// @Summary (Admin) Update variant stock
// @Description (Shop/Admin) Set tồn kho tuyệt đối cho 1 biến thể. Đồng thời cập nhật total_stock và ACTIVE/INACTIVE theo tổng tồn.
// @Security Bearer
// @Tags Products
// @Accept json
// @Produce json
// @Param variant_id path int true "Variant ID"
// @Param body body api.UpdateVariantStockRequest true "Stock"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/product-variants/{variant_id}/stock [put]
func (c *CatalogController) AdminUpdateVariantStock(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	variantID64, err := strconv.ParseUint(chi.URLParam(r, "variant_id"), 10, 64)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid variant_id")
		return
	}
	var req api.UpdateVariantStockRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	// update variant stock
	var v repositories.ProductVariantModel
	tx := c.db.WithContext(r.Context()).Begin()
	if err := tx.Where("id = ?", uint(variantID64)).First(&v).Error; err != nil {
		tx.Rollback()
		if err == gorm.ErrRecordNotFound {
			resp.Error(w, http.StatusNotFound, "variant not found")
			return
		}
		resp.Error(w, http.StatusInternalServerError, "failed to load variant")
		return
	}
	if err := tx.Model(&repositories.ProductVariantModel{}).Where("id = ?", v.ID).Update("stock", req.Stock).Error; err != nil {
		tx.Rollback()
		resp.Error(w, http.StatusInternalServerError, "failed to update stock")
		return
	}
	var sum int64
	if err := tx.Model(&repositories.ProductVariantModel{}).Where("product_id = ?", v.ProductID).Select("COALESCE(SUM(stock),0)").Scan(&sum).Error; err != nil {
		tx.Rollback()
		resp.Error(w, http.StatusInternalServerError, "failed to recompute total stock")
		return
	}
	_ = tx.Model(&repositories.ProductStatsModel{}).Where("product_id = ?", v.ProductID).Update("total_stock", int(sum)).Error
	// update product status based on total stock
	status := "INACTIVE"
	if sum > 0 {
		status = "ACTIVE"
	}
	_ = tx.Model(&repositories.ProductModel{}).Where("id = ?", v.ProductID).Update("status", status).Error

	if err := tx.Commit().Error; err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to commit")
		return
	}
	resp.OK(w, map[string]bool{"ok": true})
}

// @Summary (Admin) Update variant
// @Description (Shop/Admin) Cập nhật thông tin biến thể (hiện hỗ trợ SKU).
// @Security Bearer
// @Tags Products
// @Accept json
// @Produce json
// @Param variant_id path int true "Variant ID"
// @Param body body api.UpdateVariantRequest true "Variant"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/product-variants/{variant_id} [put]
func (c *CatalogController) AdminUpdateVariant(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	variantID64, err := strconv.ParseUint(chi.URLParam(r, "variant_id"), 10, 64)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid variant_id")
		return
	}
	var req api.UpdateVariantRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if req.Sku == "" {
		resp.Error(w, http.StatusBadRequest, "sku is required")
		return
	}

	if err := c.db.WithContext(r.Context()).Model(&repositories.ProductVariantModel{}).
		Where("id = ?", uint(variantID64)).Update("sku", req.Sku).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			resp.Error(w, http.StatusNotFound, "variant not found")
			return
		}
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	resp.OK(w, map[string]bool{"ok": true})
}

