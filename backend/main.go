// backend/main.go
package main

import (
	"gbox/handlers" // Use your module name here
	"log"
	"os"

	"github.com/gin-gonic/gin"
)

// setupDirectories ensures that the necessary directories for storage exist.
func setupDirectories() {
	if err := os.MkdirAll(UploadPath, 0755); err != nil {
		log.Fatalf("Failed to create upload directory: %v", err)
	}
	if err := os.MkdirAll(MediaPath, 0755); err != nil {
		log.Fatalf("Failed to create media directory: %v", err)
	}
}

func main() {
	// Initial setup
	setupDirectories()
	ConnectDatabase()
	MigrateDatabase()

	// Initialize Gin router
	r := gin.Default()

	// Serve static files (transcoded videos and thumbnails)
	// This makes the content in the MediaPath accessible via the /media URL path.
	r.Static("/media", MediaPath)

	// Dependency Injection: Create handler instance with the DB connection
	videoHandler := handlers.NewVideoHandler(DB)

	// Group API routes under /api
	api := r.Group("/api")
	{
		api.POST("/videos", videoHandler.UploadVideo)
		api.GET("/videos", videoHandler.GetVideos)
		api.GET("/videos/:uuid", videoHandler.GetVideoDetail)
	}

	// Start the server
	log.Printf("Starting server on port %s", ServerPort)
	if err := r.Run(ServerPort); err != nil {
		log.Fatalf("Failed to run server: %v", err)
	}
}
