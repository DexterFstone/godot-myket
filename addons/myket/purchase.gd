class_name Purchase
extends RefCounted

var item_type: String
var order_id: String
var sku: String
var purchase_time: int
var purchase_state: int
var developer_payload: String
var token: String
var original_json: String
var package_name: String
var signature: String

func _init(info: Dictionary) -> void:
	item_type = info.get("item_type", "")
	order_id = info.get("order_id", "")
	sku = info.get("sku", "")
	purchase_time = info.get("purchase_time", -1)
	purchase_state = info.get("purchase_state", -1)
	developer_payload = info.get("developer_payload", "")
	token = info.get("token", "")
	original_json = info.get("original_json", "")
	package_name = info.get("package_name", "")
	signature = info.get("signature", "")

func get_item_type() -> String:
	return item_type

func get_original_json() -> String:
	return original_json

func get_signature() -> String:
	return signature
