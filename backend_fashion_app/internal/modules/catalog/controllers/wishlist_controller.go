package controllers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/modules/catalog/api"
	"myfashion/internal/modules/catalog/repositories"
)

// @Summary Add product to wishlist
// @Description Thêm sản phẩm vào danh sách yêu thích của user hiện tại.
// @Security Bearer
// @Tags Wishlist
// @Accept json
// @Produce json
// @Param body body api.WishlistItemRequest true "Payload"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 404 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /wishlist/items [post]
func (c *CatalogController) AddWishlistItem(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var req api.WishlistItemRequest
	if err := decodeJSON(r, &req); err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid body")
		return
	}
	if req.ProductID == 0 {
		resp.Error(w, http.StatusBadRequest, "product_id is required")
		return
	}

	// Ensure product exists
	productRepo := repositories.NewProductGormRepo(c.db)
	if _, err := productRepo.GetByID(r.Context(), req.ProductID); err != nil {
		resp.Error(w, http.StatusNotFound, "product not found")
		return
	}

	wishRepo := repositories.NewWishlistRepository(c.db)
	if err := wishRepo.Add(r.Context(), claims.UID, req.ProductID); err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to add wishlist item")
		return
	}

	resp.OK(w, "added")
}

// @Summary Remove product from wishlist
// @Description Bỏ sản phẩm khỏi danh sách yêu thích của user hiện tại.
// @Security Bearer
// @Tags Wishlist
// @Produce json
// @Param product_id path int true "Product ID"
// @Success 200 {object} resp.Envelope
// @Failure 400 {object} resp.Envelope
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /wishlist/items/{product_id} [delete]
func (c *CatalogController) RemoveWishlistItem(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	idStr := chi.URLParam(r, "product_id")
	pid, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, "invalid product_id")
		return
	}

	wishRepo := repositories.NewWishlistRepository(c.db)
	if err := wishRepo.Remove(r.Context(), claims.UID, uint(pid)); err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to remove wishlist item")
		return
	}

	resp.OK(w, "removed")
}

// @Summary List wishlist products
// @Description Lấy danh sách sản phẩm yêu thích của user hiện tại.
// @Security Bearer
// @Tags Wishlist
// @Produce json
// @Param limit query int false "Limit" default(50)
// @Param offset query int false "Offset" default(0)
// @Success 200 {object} resp.Envelope{data=api.WishlistListResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /wishlist [get]
func (c *CatalogController) GetWishlist(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))

	wishRepo := repositories.NewWishlistRepository(c.db)
	ids, _, err := wishRepo.ListProductIDs(r.Context(), claims.UID, limit, offset)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to load wishlist")
		return
	}

	if len(ids) == 0 {
		resp.OK(w, api.WishlistListResponse{Items: []api.ProductSummaryResponse{}})
		return
	}

	var models []repositories.ProductModel
	q := c.db.WithContext(r.Context()).Model(&repositories.ProductModel{}).
		Where("id IN ?", ids).
		Where("UPPER(status) = ?", "ACTIVE")
	if err := q.Find(&models).Error; err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to load products")
		return
	}

	// keep order as ids
	mByID := map[uint]repositories.ProductModel{}
	for _, m := range models {
		mByID[m.ID] = m
	}

	items := make([]api.ProductSummaryResponse, 0, len(ids))
	for _, id := range ids {
		m, ok := mByID[id]
		if !ok {
			continue
		}
		items = append(items, toProductSummaryResponse(m.ToEntity(nil, nil)))
	}

	resp.OK(w, api.WishlistListResponse{Items: items})
}

func decodeJSON(r *http.Request, out any) error {
	return json.NewDecoder(r.Body).Decode(out)
}

