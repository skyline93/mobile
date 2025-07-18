// backend/database.go
package main

import (
	"log"
	"gbox/models" // Use your module name here

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// DB is a global variable that holds the database connection pool.
var DB *gorm.DB

// ConnectDatabase initializes the connection to the SQLite database.
func ConnectDatabase() {
	var err error
	DB, err = gorm.Open(sqlite.Open(DatabaseFile), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	log.Println("Database connection successful.")
}

// MigrateDatabase runs the auto-migration for our GORM models.
// This will create or update the 'videos' table to match the Video struct.
func MigrateDatabase() {
	err := DB.AutoMigrate(&models.Video{})
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}
	log.Println("Database migration successful.")
}
