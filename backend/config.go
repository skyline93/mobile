// backend/config.go
package main

// This file contains the application-wide configuration constants.
// Keeping them in one place makes it easy to manage and update.

const (
	// ServerPort is the port on which the web server will listen.
	ServerPort = ":8080"

	// DatabaseFile is the name of the SQLite database file.
	DatabaseFile = "videos.db"

	// UploadPath is the directory where original, unprocessed videos are stored.
	UploadPath = "./data/uploads"

	// MediaPath is the directory where processed HLS videos and thumbnails are stored.
	// This path will be served statically by the web server.
	MediaPath = "./data/media"
)
