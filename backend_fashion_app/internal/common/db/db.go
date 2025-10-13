package db

import (
	"log"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func Open(dsn string) *gorm.DB {
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("open db error: %v", err)
	}
	return db
}
