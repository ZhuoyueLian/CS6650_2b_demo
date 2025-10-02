package main

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// Product represents data about a product.
type Product struct {
	ProductID    int    `json:"product_id"`
	SKU          string `json:"sku"`
	Manufacturer string `json:"manufacturer"`
	CategoryID   int    `json:"category_id"`
	Weight       int    `json:"weight"`
	SomeOtherID  int    `json:"some_other_id"`
}

// products map to store product data (productID -> Product)
var products = make(map[int]Product)

func main() {
	router := gin.Default()
	router.GET("/products/:productId", getProductByID)
	router.POST("/products/:productId/details", postProductDetails)

	router.Run(":8080")
}

// getProductByID locates the product whose ID matches the id parameter
func getProductByID(c *gin.Context) {
	// 1. Get the id from URL parameter and convert it to int
	idStr := c.Param("productId") // Note: it's "productId" not "id"

	// Convert string id to int
	idInt, err := strconv.Atoi(idStr)
	if err != nil {
		c.IndentedJSON(http.StatusBadRequest, gin.H{"message": "invalid product ID format"})
		return
	}

	// 2. Look up the product in the map
	product, exists := products[idInt]

	// 3. If exists, return it with StatusOK
	if exists {
		c.IndentedJSON(http.StatusOK, product)
	} else {
		c.IndentedJSON(http.StatusNotFound, gin.H{"error": "NOT_FOUND", "message": "product not found"})
	}
}

// postProductDetails adds or updates product details
func postProductDetails(c *gin.Context) {
	// 1. Get productId from URL and convert to int
	idStr := c.Param("productId")

	idInt, err := strconv.Atoi(idStr)
	if err != nil {
		c.IndentedJSON(http.StatusBadRequest, gin.H{"message": "invalid product ID format"})
		return
	}

	// 2. Bind the JSON body to a Product struct
	var newProduct Product
	if err := c.BindJSON(&newProduct); err != nil {
		c.IndentedJSON(http.StatusBadRequest, gin.H{"message": "invalid input data"})
		return
	}

	// 3. Store in the map using the ID from the URL
	products[idInt] = newProduct

	// 4. Return 204 No Content
	c.Status(http.StatusNoContent)
}
