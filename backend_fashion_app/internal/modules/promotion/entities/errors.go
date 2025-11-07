package entities

import "errors"

// Lỗi nghiệp vụ cho module Promotion
var (
	ErrPromotionNotFound              = errors.New("mã khuyến mãi không tồn tại")
	ErrPromotionExpired               = errors.New("mã khuyến mãi đã hết hạn")
	ErrPromotionNotActive             = errors.New("mã khuyến mãi chưa được kích hoạt")
	ErrPromotionUsageLimitReached     = errors.New("mã khuyến mãi đã hết lượt sử dụng")
	ErrPromotionUserUsageLimitReached = errors.New("bạn đã hết lượt sử dụng mã khuyến mãi này")
	ErrPromotionMinOrderValueNotMet   = errors.New("đơn hàng chưa đạt giá trị tối thiểu để áp dụng mã")
	ErrPromotionNotApplicableToUser   = errors.New("mã khuyến mãi không áp dụng cho tài khoản của bạn")
	ErrPromotionNotStackable          = errors.New("mã khuyến mãi không thể sử dụng chung với các mã khác")
	ErrPromotionCodeExists            = errors.New("mã khuyến mãi đã tồn tại")
)
