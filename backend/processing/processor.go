// backend/processing/processor.go
package processing

import (
	"gbox/models" // Use your module name here
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"gorm.io/gorm"
)

// ProcessVideo is a long-running function that handles video transcoding.
// It is intended to be run in a separate Goroutine.
func ProcessVideo(video models.Video, db *gorm.DB) {
	log.Printf("Starting processing for video UUID: %s", video.UUID)

	mediaDir := filepath.Join("./data/media", video.UUID)
	if err := os.MkdirAll(mediaDir, 0755); err != nil {
		log.Printf("Error creating media directory for %s: %v", video.UUID, err)
		updateStatus(db, &video, models.StatusFailed)
		return
	}

	// 1. Generate Thumbnail
	thumbnailPath := filepath.Join(mediaDir, "thumbnail.jpg")
	cmdThumb := exec.Command("ffmpeg", "-i", video.OriginalPath, "-ss", "00:00:01", "-vframes", "1", thumbnailPath)
	if output, err := cmdThumb.CombinedOutput(); err != nil {
		log.Printf("Error generating thumbnail for %s: %v\nOutput: %s", video.UUID, err, string(output))
		updateStatus(db, &video, models.StatusFailed)
		return
	}
	log.Printf("Thumbnail generated for %s", video.UUID)

	// 2. Transcode to HLS
	hlsPath := filepath.Join(mediaDir, "playlist.m3u8")
	cmdHLS := exec.Command("ffmpeg", "-i", video.OriginalPath, "-c:a", "aac", "-c:v", "libx264", "-hls_time", "6", "-hls_list_size", "0", "-f", "hls", hlsPath)
	if output, err := cmdHLS.CombinedOutput(); err != nil {
		log.Printf("Error transcoding to HLS for %s: %v\nOutput: %s", video.UUID, err, string(output))
		updateStatus(db, &video, models.StatusFailed)
		return
	}
	log.Printf("HLS transcoding complete for %s", video.UUID)

	// 3. Update database record on success
	updates := models.Video{
		Status:        models.StatusReady,
		HLSPath:       hlsPath,
		ThumbnailPath: thumbnailPath,
	}

	if result := db.Model(&video).Updates(updates); result.Error != nil {
		log.Printf("Error updating video status to ready for %s: %v", video.UUID, result.Error)
	} else {
		log.Printf("Successfully processed video UUID: %s", video.UUID)
	}
}

// updateStatus is a helper function to update the video status in the database.
func updateStatus(db *gorm.DB, video *models.Video, status models.VideoStatus) {
	db.Model(video).Update("status", status)
}
