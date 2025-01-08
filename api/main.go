package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"lost-item-hub/api/model"
)

// インメモリでアイテムを保存（本番環境ではデータベースを使用）
var items = make(map[string]model.Item)

func main() {
	// ログの設定
	log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds)
	
	r := gin.Default()

	// CORS設定
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// アイテムを登録
	r.POST("/items", func(c *gin.Context) {
		// リクエストボディの内容をログに出力
		body, err := c.GetRawData()
		if err != nil {
			log.Printf("リクエストボディの読み取りに失敗: %v\n", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read request body"})
			return
		}
		log.Printf("\n[リクエストボディ]\n%s\n", string(body))

		// リクエストボディを再設定
		c.Request.Body = io.NopCloser(bytes.NewBuffer(body))

		var item model.Item
		if err := c.ShouldBindJSON(&item); err != nil {
			log.Printf("\n[JSONバインドエラー] %v\n", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		// バインドされたデータをログに出力
		log.Printf("\n[バインドされたデータ]\n")
		log.Printf("ItemName: %s\n", item.ItemName)
		log.Printf("ItemColor: %s\n", item.ItemColor)
		log.Printf("ItemDescription: %s\n", item.ItemDescription)
		log.Printf("NeedsReceipt: %v\n", item.NeedsReceipt)
		log.Printf("RouteName: %s\n", item.RouteName)
		log.Printf("VehicleNumber: %s\n", item.VehicleNumber)
		if item.OtherLocation != nil {
			log.Printf("OtherLocation: %s\n", *item.OtherLocation)
		}
		log.Printf("Images: %v\n", item.Images)
		log.Printf("FinderName: %s\n", item.FinderName)
		if item.FinderPhone != nil {
			log.Printf("FinderPhone: %s\n", *item.FinderPhone)
		}
		if item.PostalCode != nil {
			log.Printf("PostalCode: %s\n", *item.PostalCode)
		}
		if item.FinderAddress != nil {
			log.Printf("FinderAddress: %s\n", *item.FinderAddress)
		}
		if item.Cash != nil {
			log.Printf("Cash: %d\n", *item.Cash)
		}

		// IDと時刻を設定
		item.ID = uuid.New().String()
		item.CreatedAt = time.Now()
		item.UpdatedAt = time.Now()

		// アイテムを保存
		items[item.ID] = item

		// レスポンスデータをログに出力
		responseJSON, _ := json.MarshalIndent(item, "", "  ")
		log.Printf("\n[レスポンスデータ]\n%s\n", string(responseJSON))

		c.JSON(http.StatusCreated, item)
	})

	// アイテムの一覧を取得
	r.GET("/items", func(c *gin.Context) {
		itemList := make([]model.Item, 0, len(items))
		for _, item := range items {
			itemList = append(itemList, item)
		}
		c.JSON(http.StatusOK, itemList)
	})

	// アイテムを取得
	r.GET("/items/:id", func(c *gin.Context) {
		id := c.Param("id")
		item, exists := items[id]
		if !exists {
			c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
			return
		}
		c.JSON(http.StatusOK, item)
	})

	// サーバーを起動（デフォルトポート: 8080）
	log.Println("サーバーを起動: http://localhost:8080")
	r.Run(":8080")  // 0.0.0.0:8080 でリッスン
}
