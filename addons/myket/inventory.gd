class_name Inventory
extends RefCounted

var sku_details_list: Array[SkuDetails]
var purchase_list: Array[Purchase]

func _init(info: Dictionary) -> void:
	var products: Dictionary = info.products
	var purchases: Dictionary = info.purchases
	for product: Dictionary in products.values():
		var new_sku_details: SkuDetails = SkuDetails.new(product)
		add_sku_details(new_sku_details)
	for purchase: Dictionary in purchases.values():
		var new_purchase: Purchase = Purchase.new(purchase)
		add_sku_purchase(new_purchase)

func add_sku_details(sku_details: SkuDetails) -> void:
	sku_details_list.append(sku_details)

func add_sku_purchase(purchase: Purchase) -> void:
	purchase_list.append(purchase)

func get_sku_details(sku: String) -> SkuDetails:
	for sku_details: SkuDetails in sku_details_list:
		if sku_details.sku != sku: continue
		return sku_details
	return null

func get_purchase(sku: String) -> Purchase:
	for purchase: Purchase in purchase_list:
		if purchase.sku != sku: continue
		return purchase
	return null

func has_purchase(sku: String) -> bool:
	for purchase: Purchase in purchase_list:
		if purchase.sku != sku: continue
		return true
	return false

func has_sku_details(sku: String) -> bool:
	for sku_details: SkuDetails in sku_details_list:
		if sku_details.sku != sku: continue
		return true
	return false

func erase_purchase(sku: String) -> void:
	for purchase: Purchase in purchase_list:
		if purchase.sku != sku: continue
		purchase_list.erase(purchase)

func erase_sku_details(sku: String) -> void:
	for sku_details: SkuDetails in sku_details_list:
		if sku_details.sku != sku: continue
		sku_details_list.erase(sku_details)

func get_all_owned_skus(item_time: String = "") -> Array[String]:
	var owned_skus: Array[String]
	if item_time.is_empty():
		for purchase: Purchase in purchase_list:
			owned_skus.append(purchase.sku)
	else :
		for purchase: Purchase in purchase_list:
			if purchase.item_type != item_time: continue
			owned_skus.append(purchase.sku)
	return owned_skus

func get_all_purchases() -> Array[Purchase]:
		return purchase_list

func get_all_products() -> Array[SkuDetails]:
		return sku_details_list
