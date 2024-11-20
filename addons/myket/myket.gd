@icon("res://addons/myket/icon.svg")
class_name Myket
extends Node

signal connection_succeed
signal connection_failed(message: String)
signal query_inventory_finished(is_success: bool, message: String, inventory: Myket.Inventory)
signal query_inventory_failed(message: String)
signal iab_purchase_finished(is_success: bool, message: String, purchase: Myket.Purchase)
signal iab_purchase_failed(message: String)
signal consume_finished(is_success: bool, message: String, purchase: Myket.Purchase)
signal consume_failed(message: String)

@export var public_key: String

var _plugin: JNISingleton
var _plugin_name: String = "GodotMyket"

func _ready() -> void:
	connect_to_myket()

func connect_to_myket(public_key: String = "") -> void:
	if self.public_key.is_empty():
		self.public_key = public_key
	if self.public_key.is_empty(): return
	if not _has_singleton(): return
	_plugin = _get_singleton()
	_plugin.connect_to_myket(self.public_key)
	if not _plugin.is_connected("connection_succeed", __on_connection_succeed):
		_plugin.connection_succeed.connect(__on_connection_succeed, CONNECT_ONE_SHOT)
	if not _plugin.is_connected("connection_failed", __on_connection_failed):
		_plugin.connection_failed.connect(__on_connection_failed, CONNECT_ONE_SHOT)

func query_inventory_async(query_sku_details: bool, item_skus: Array[String]) -> void:
	if not _has_myket(): return
	_plugin.query_inventory_async(query_sku_details, item_skus)
	if not _plugin.is_connected("query_inventory_finished", __on_query_inventory_finished):
		_plugin.query_inventory_finished.connect(__on_query_inventory_finished, CONNECT_ONE_SHOT)
	if not _plugin.is_connected("query_inventory_failed", __on_query_inventory_failed):
		_plugin.query_inventory_failed.connect(__on_query_inventory_failed, CONNECT_ONE_SHOT)

func launch_purchase_flow(sku: String, payload: String = "") -> void:
	if not _has_myket(): return
	_plugin.launch_purchase_flow(sku, payload)
	if not _plugin.is_connected("iab_purchase_finished", __on_iab_purchase_finished):
		_plugin.iab_purchase_finished.connect(__on_iab_purchase_finished, CONNECT_ONE_SHOT)
	if not _plugin.is_connected("iab_purchase_failed", __on_iab_purchase_failed):
		_plugin.iab_purchase_failed.connect(__on_iab_purchase_failed, CONNECT_ONE_SHOT)

func consume_async(purchase: Purchase) -> void:
	if not _has_myket(): return
	_plugin.consume_async(purchase._get_data())
	if not _plugin.is_connected("consume_finished", __on_consume_finished):
		_plugin.consume_finished.connect(__on_consume_finished, CONNECT_ONE_SHOT)
	if not _plugin.is_connected("consume_failed", __on_consume_failed):
		_plugin.consume_failed.connect(__on_consume_failed, CONNECT_ONE_SHOT)

func disconnect_from_myket() -> void:
	if not _has_myket(): return
	_plugin.disconnect_from_myket()
	_plugin.free()
	_plugin = null

func _has_myket() -> bool:
	return is_instance_valid(_plugin)

func _has_singleton() -> bool:
	return Engine.has_singleton(_plugin_name)

func _get_singleton() -> Object:
	return Engine.get_singleton(_plugin_name)

func __on_connection_succeed() -> void:
	connection_succeed.emit()

func __on_connection_failed(message: String) -> void:
	connection_failed.emit(message)

func __on_query_inventory_finished(is_success: bool, message: String, inventory: Dictionary) -> void:
	var new_inventory: Inventory = Inventory.new(inventory)
	query_inventory_finished.emit(is_success, message, new_inventory)

func __on_query_inventory_failed(message: String) -> void:
	query_inventory_failed.emit(message)

func __on_iab_purchase_finished(is_success: bool, message: String, purchase: Dictionary) -> void:
	var new_purchase: Purchase = Purchase.new(purchase)
	iab_purchase_finished.emit(is_success, message, new_purchase)

func __on_iab_purchase_failed(message: String) -> void:
	iab_purchase_failed.emit(message)

func __on_consume_finished(is_success: bool, message: String, purchase: Dictionary) -> void:
	var new_purchase: Purchase = Purchase.new(purchase)
	consume_finished.emit(is_success, message, new_purchase)

func __on_consume_failed(message: String) -> void:
	consume_failed.emit(message)

class SkuDetails extends RefCounted:

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

class Purchase extends RefCounted:

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

	func _get_data() -> Dictionary:
		var new_purchase: Dictionary = {
			"item_type" : item_type,
			"original_json" : original_json,
			"signature" : signature
		}
		return new_purchase

class Inventory extends RefCounted:

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
