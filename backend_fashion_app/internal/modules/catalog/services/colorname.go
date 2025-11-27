package services

import (
	"strings"
)

// MapColorNameFromHex returns a coarse Vietnamese color name nearest to hex.
// Simple heuristic; can be improved later.
func MapColorNameFromHex(hex string) string {
	h := strings.TrimSpace(strings.ToLower(hex))
	// common base colors
	switch h {
	case "#000000":
		return "Đen"
	case "#ffffff":
		return "Trắng"
	case "#ff0000":
		return "Đỏ"
	case "#00ff00":
		return "Xanh lá"
	case "#0000ff":
		return "Xanh dương"
	case "#ffff00":
		return "Vàng"
	case "#808080":
		return "Xám"
	}
	// fallback by prefix
	if strings.HasPrefix(h, "#ff") {
		return "Đỏ"
	}
	if strings.HasPrefix(h, "#00ff") {
		return "Xanh lá"
	}
	if strings.HasPrefix(h, "#0000") {
		return "Xanh dương"
	}
	if strings.HasPrefix(h, "#ffff") {
		return "Vàng"
	}
	return "Khác"
}
