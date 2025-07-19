// backend/handlers/video_handler.go
package handlers

import (
	"gbox/models"     // Use your module name here
	"gbox/processing" // Use your module name here
	"net/http"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// type Response struct {
// 	Message string `json:"message"`
// 	VideoId string `json:"videoId,omitempty"`
// }

// VideoHandler holds the database connection for video-related handlers.
type VideoHandler struct {
	DB *gorm.DB
}

// NewVideoHandler creates a new VideoHandler with a database connection.
func NewVideoHandler(db *gorm.DB) *VideoHandler {
	return &VideoHandler{DB: db}
}

// UploadVideo handles the video file upload.
func (h *VideoHandler) UploadVideo(c *gin.Context) {
	title := c.PostForm("title")
	file, err := c.FormFile("video")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Video file not provided"})
		return
	}
	if title == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Title not provided"})
		return
	}

	newUUID := uuid.New().String()
	originalPath := filepath.Join("./data/uploads", newUUID+filepath.Ext(file.Filename))

	if err := c.SaveUploadedFile(file, originalPath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}

	video := models.Video{
		UUID:         newUUID,
		Title:        title,
		Status:       models.StatusProcessing,
		OriginalPath: originalPath,
	}
	if result := h.DB.Create(&video); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create video record"})
		return
	}

	// Start video processing asynchronously in a new Goroutine
	go processing.ProcessVideo(video, h.DB)

	// Immediately respond to the client
	c.JSON(http.StatusAccepted, gin.H{"message": "Video upload accepted and is being processed", "videoId": video.UUID})
}

// GetVideos retrieves a list of all videos that are ready to be played.
func (h *VideoHandler) GetVideos(c *gin.Context) {
	var videos []models.Video
	result := h.DB.Where("status = ?", models.StatusReady).Order("created_at desc").Find(&videos)
	if result.Error != nil {
		ErrorResp(c, result.Error, http.StatusInternalServerError)
		return
	}

	type VideoResponse struct {
		UUID         string `json:"uuid"`
		Title        string `json:"title"`
		ThumbnailURL string `json:"thumbnail_url"`
	}

	var response []VideoResponse = make([]VideoResponse, 0, len(videos))
	for _, v := range videos {
		response = append(response, VideoResponse{
			UUID:         v.UUID,
			Title:        v.Title,
			ThumbnailURL: "/media/" + v.UUID + "/thumbnail.jpg",
		})
	}
	SuccessResp(c, response)
}

// GetVideoDetail retrieves details for a single video.
func (h *VideoHandler) GetVideoDetail(c *gin.Context) {
	uuid := c.Param("uuid")
	var video models.Video
	if err := h.DB.Where("uuid = ?", uuid).First(&video).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Video not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	if video.Status != models.StatusReady {
		c.JSON(http.StatusOK, gin.H{"status": string(video.Status), "title": video.Title})
		return
	}

	response := gin.H{
		"uuid":    video.UUID,
		"title":   video.Title,
		"status":  string(video.Status),
		"hls_url": "/media/" + video.UUID + "/playlist.m3u8",
	}
	c.JSON(http.StatusOK, response)
}
