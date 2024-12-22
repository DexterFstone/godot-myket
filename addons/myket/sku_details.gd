class_name SkuDetails
extends RefCounted

var sku: String
var type: String
var price: String
var title: String
var description: String

func _init(info: Dictionary) -> void:
	sku = info.get("sku", "")
	type = info.get("type", "")
	price = info.get("price", "")
	title = info.get("title", "")
	description = info.get("description", "")
