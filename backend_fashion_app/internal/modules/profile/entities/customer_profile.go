package entities

type CustomerProfile struct {
	UserID   uint
	FullName string
	Age      int
	Gender   string
	Address  string
	Tier     string // Hạng thành viên: bronze, silver, gold
	ImgURL   string
}
