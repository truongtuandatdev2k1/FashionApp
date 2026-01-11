package entities

import "errors"

var (
	ErrNotificationNotFound   = errors.New("notification not found")
	ErrUnauthorizedAccess     = errors.New("unauthorized access")
	ErrInvalidTarget          = errors.New("invalid target")
	ErrEmptyUserIDs           = errors.New("user_ids is required")
)

