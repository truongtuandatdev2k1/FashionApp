package services

import "math"

// ComputePriceAfter tính price_after = round(price * (1 - discountPct/100), 2)
func ComputePriceAfter(price float64, discountPct int) float64 {
	if discountPct <= 0 {
		return round2(price)
	}
	if discountPct > 100 {
		discountPct = 100
	}
	d := price * (1 - float64(discountPct)/100.0)
	return round2(d)
}

func round2(x float64) float64 {
	return math.Round(x*100) / 100
}
