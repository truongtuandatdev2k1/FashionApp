package resp

import (
	"encoding/json"
	"net/http"
)

type Envelope struct {
	Code    string      `json:"code"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}

func JSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func OK(w http.ResponseWriter, data interface{}) {
	JSON(w, http.StatusOK, Envelope{Code: "OK", Data: data})
}
func Created(w http.ResponseWriter, data interface{}) {
	JSON(w, http.StatusCreated, Envelope{Code: "CREATED", Data: data})
}
func Error(w http.ResponseWriter, status int, msg string) {
	JSON(w, status, Envelope{Code: "ERR", Message: msg})
}
