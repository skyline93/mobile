package handlers

import (
	"github.com/gin-gonic/gin"
)

// Resp represents a generic API response structure
type Resp[T any] struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Data    T      `json:"data"`
}

// BaseResp represents a basic API response without data
type BaseResp struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

// StringResp represents a response with string data
type StringResp struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Data    string `json:"data"`
}

// StringArrayResp represents a response with string array data
type StringArrayResp struct {
	Code    int      `json:"code"`
	Message string   `json:"message"`
	Data    []string `json:"data"`
}

// TokenResp represents a response with token data
type TokenResp struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Data    gin.H  `json:"data"`
}

// ErrorStrResp sends an error response with a string message
func ErrorStrResp(c *gin.Context, str string, code int, l ...bool) {
	if len(l) != 0 && l[0] {
		// log.Error(str)
	}
	c.JSON(200, Resp[interface{}]{
		Code:    code,
		Message: str,
		Data:    nil,
	})
	c.Abort()
}

// SuccessResp sends a success response
func SuccessResp(c *gin.Context, data ...interface{}) {
	if len(data) == 0 {
		c.JSON(200, Resp[interface{}]{
			Code:    0,
			Message: "success",
			Data:    nil,
		})
		return
	}
	c.JSON(200, Resp[interface{}]{
		Code:    0,
		Message: "success",
		Data:    data[0],
	})
}

// ErrorWithDataResp sends an error response with data
func ErrorWithDataResp(c *gin.Context, err error, code int, data interface{}, l ...bool) {
	c.JSON(200, Resp[interface{}]{
		Code:    code,
		Message: err.Error(),
		Data:    data,
	})
	c.Abort()
}

// ErrorResp sends an error response
func ErrorResp(c *gin.Context, err error, code int, l ...bool) {
	ErrorWithDataResp(c, err, code, nil, l...)
}
