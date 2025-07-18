// backend/models/video.go
package models

import "gorm.io/gorm"

// VideoStatus defines the possible states a video can be in during its lifecycle.
type VideoStatus string

const (
	StatusProcessing VideoStatus = "processing"
	StatusReady      VideoStatus = "ready"
	StatusFailed     VideoStatus = "failed"
)

// Video is the GORM model representing the `videos` table in the database.
type Video struct {
	// gorm.Model provides default fields: ID, CreatedAt, UpdatedAt, DeletedAt
	gorm.Model

	UUID          string `gorm:"type:varchar(36);uniqueIndex"`
	Title         string
	Status        VideoStatus `gorm:"type:varchar(20);default:'processing'"`
	OriginalPath  string      // Path to the original uploaded video file
	HLSPath       string      // Path to the generated HLS playlist (.m3u8)
	ThumbnailPath string      // Path to the generated thumbnail image
}
