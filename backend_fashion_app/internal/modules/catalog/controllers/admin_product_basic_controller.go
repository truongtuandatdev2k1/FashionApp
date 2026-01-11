package controllers

import (
	"encoding/json"
	"net/http"

	"myfashion/internal/common/resp"
	"myfashion/internal/common/validation"
	"myfashion/internal/modules/catalog/api"
	"myfashion/internal/modules/catalog/services"
)

// @Summary (Admin) Update product basic
// @Description (Shop/Admin) Cập nhật thông tin cơ bản của sản phẩm (name/price/discount/brand/categories/styles...).
// @Security Bearer
// @Tags Products
// @Accept json
// @Produce json
// @Param id path int true "Product ID"
// @Param body body api.AdminUpdateProductBasicRequest true "Product basic"
// @Success 200 {object} resp.Envelope{data=api.ProductDetailResponse}
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 403 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /admin/products/{id}/basic [put]
func (c *CatalogController) AdminUpdateProductBasic(w http.ResponseWriter, r *http.Request) {
	if !c.isShop(r) {
		resp.Error(w, http.StatusForbidden, "forbidden: shop access required")
		return
	}
	productID, ok := c.parseID(w, r, "id")
	if !ok {
		return
	}
	var req api.AdminUpdateProductBasicRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := validation.Validate(req); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	prod, err := c.productSvc.GetProduct(r.Context(), productID)
	if err != nil || prod == nil {
		resp.Error(w, http.StatusNotFound, "product not found")
		return
	}

	prod.Name = req.Name
	prod.Price = req.Price
	prod.DiscountPct = req.DiscountPct
	prod.PriceAfter = services.ComputePriceAfter(req.Price, req.DiscountPct)
	prod.AgeRange = req.AgeRange
	prod.Description = req.Description
	prod.IsHotTrend = req.IsHotTrend
	if req.BrandID != nil {
		if *req.BrandID == 0 {
			prod.BrandID = nil
		} else {
			prod.BrandID = req.BrandID
		}
	}

	if err := c.prodRepo.Update(r.Context(), prod); err != nil {
		resp.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if req.CategoryIDs != nil {
		_ = c.productSvc.AssignCategoriesToProduct(r.Context(), productID, req.CategoryIDs)
	}
	if req.StyleIDs != nil {
		_ = c.productSvc.AssignStylesToProduct(r.Context(), productID, req.StyleIDs)
	}

	final, err := c.productSvc.GetProduct(r.Context(), productID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to fetch product")
		return
	}
	resp.OK(w, api.ToProductDetailResponse(final))
}

