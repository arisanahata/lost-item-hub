package model

import "time"

// Item は忘れ物アイテムを表す構造体です
type Item struct {
	ID              string    `json:"id"`
	ItemName        string    `json:"itemName"`
	Cash            *int      `json:"cash,omitempty"`
	ItemColor       string    `json:"itemColor"`
	ItemDescription string    `json:"itemDescription"`
	NeedsReceipt    bool      `json:"needsReceipt"`
	RouteName       string    `json:"routeName"`
	VehicleNumber   string    `json:"vehicleNumber"`
	OtherLocation   *string   `json:"otherLocation,omitempty"`
	Images          []string  `json:"images"`
	FinderName      string    `json:"finderName"`
	FinderPhone     *string   `json:"finderPhone,omitempty"`
	PostalCode      *string   `json:"postalCode,omitempty"`
	FinderAddress   *string   `json:"finderAddress,omitempty"`
	CreatedAt       time.Time `json:"createdAt"`
	UpdatedAt       time.Time `json:"updatedAt"`
}
