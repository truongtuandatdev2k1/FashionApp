package controllers

import (
	"net/http"
	"strconv"

	"myfashion/internal/common/authn"
	"myfashion/internal/common/resp"
	"myfashion/internal/modules/catalog/api"
	"myfashion/internal/modules/catalog/repositories"
)

// @Summary Get personalized recommendations for user
// @Description Gợi ý cá nhân hoá dựa trên giỏ hàng > đơn hàng > lịch sử xem, kết hợp brand/giá (và các tín hiệu khác theo repo).
// @Security Bearer
// @Tags Recommendations
// @Produce json
// @Param limit query int false "Limit" default(10)
// @Success 200 {object} resp.Envelope{data=[]api.ProductSummaryResponse}
// @Failure 401 {object} resp.Envelope
// @Failure 500 {object} resp.Envelope
// @Router /recommendations/for-you [get]
func (c *CatalogController) GetForYouRecommendations(w http.ResponseWriter, r *http.Request) {
	claims := authn.GetClaims(r.Context())
	if claims == nil {
		resp.Error(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit <= 0 || limit > 50 {
		limit = 10
	}

	repo := repositories.NewForYouRecommendationRepository(c.db)
	products, err := repo.GetForYou(r.Context(), repositories.ForYouRequest{UserID: claims.UID, Limit: limit})
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, "failed to get recommendations")
		return
	}

	if len(products) == 0 {
		resp.OK(w, []api.ProductSummaryResponse{})
		return
	}

	res := make([]api.ProductSummaryResponse, len(products))
	for i, p := range products {
		res[i] = toProductSummaryResponse(p)
	}

	resp.OK(w, res)
}
