@icon("res://addons/myket/icon.svg")
@abstract
class_name Myket
extends Object

static var _singleton: JNISingleton
static var _singleton_name: String = "GodotMyket"

## [codeblock]
## 	Myket.open_connection(PUBLIC_KEY,
## 		func connection_succeed() -> void:
## 			return, # Connection succeed
## 		
## 		func connection_failed(message: String) -> void:
## 			return # Connection failed
## 	)
## [/codeblock]
static func open_connection(public_key: String, succeed: Callable, failed: Callable) -> void:
	if public_key.is_empty():
		return
	
	if not _has_singleton():
		return
	
	_singleton = _get_singleton()
	_singleton.open_connection(public_key)
	
	var connection_succeed: Callable = func () -> void:
		succeed.call()
	
	var connection_failed: Callable = func (message: String) -> void:
		failed.call(message)
	
	if not _singleton.connection_succeed.is_connected(connection_succeed):
		_singleton.connection_succeed.connect(connection_succeed, CONNECT_ONE_SHOT)
	
	if not _singleton.connection_failed.is_connected(connection_failed):
		_singleton.connection_failed.connect(connection_failed, CONNECT_ONE_SHOT)

## [codeblock]
## 	Myket.query_inventory_async(QUERY_SKU_DETAILS, ITEM_SKUS,
## 		func query_inventory_finished(is_success: bool, message: String, inventory: Myket.Inventory) -> void:
## 			return, # Query inventory finished
## 		
## 		func query_inventory_failed(message: String) -> void:
## 			return # Query inventory failed
## 		
## 	)
## [/codeblock]
static func query_inventory_async(query_sku_details: bool, item_skus: Array[String], finished: Callable, failed: Callable) -> void:
	if not _has_myket():
		return
	
	_singleton.query_inventory_async(query_sku_details, item_skus)
	
	var query_inventory_finished: Callable = func (is_success: bool, message: String, inventory: Dictionary) -> void:
		finished.call(is_success, message, Inventory.new(inventory))
	
	var query_inventory_failed: Callable = func (message: String) -> void:
		failed.call(message)
	
	if not _singleton.query_inventory_finished.is_connected(query_inventory_finished):
		_singleton.query_inventory_finished.connect(query_inventory_finished, CONNECT_ONE_SHOT)
	
	if not _singleton.query_inventory_failed.is_connected(query_inventory_failed):
		_singleton.query_inventory_failed.connect(query_inventory_failed, CONNECT_ONE_SHOT)

## [codeblock]
## 	Myket.launch_purchase_flow(SKU, PAYLOAD,
## 		func iab_purchase_finished(is_success: bool, message: String, purchase: Myket.Purchase) -> void:
## 			return, # IAB purchase finished
## 		
## 		func iab_purchase_failed(message: String) -> void:
## 			return # IAB purchase failed
## 	)
## [/codeblock]
static func launch_purchase_flow(sku: String, payload: String, finished: Callable, failed: Callable) -> void:
	if not _has_myket():
		return
	
	_singleton.launch_purchase_flow(sku, payload)
	var iab_purchase_finished: Callable = func (is_success: bool, message: String, purchase: Dictionary) -> void:
		finished.call(is_success, message, Purchase.new(purchase))
	
	var iab_purchase_failed: Callable = func (message: String) -> void:
		failed.call(message)
	
	if not _singleton.iab_purchase_finished.is_connected(iab_purchase_finished):
		_singleton.iab_purchase_finished.connect(iab_purchase_finished, CONNECT_ONE_SHOT)
	
	if not _singleton.iab_purchase_failed.is_connected(iab_purchase_failed):
		_singleton.iab_purchase_failed.connect(iab_purchase_failed, CONNECT_ONE_SHOT)


## [codeblock]
## Myket.consume_async(purchase, 
## 		func consume_finished(is_success: bool, message: String, purchase: Myket.Purchase) -> void:
## 			return, # Consume finished
## 		
## 		func consume_failed(message: String) -> void:
## 			return # Consume failed
## 	)
## [/codeblock]
static func consume_async(purchase: Purchase, finished: Callable, failed: Callable) -> void:
	if not _has_myket():
		return
	
	if not is_instance_valid(purchase):
		failed.call("Invalid purchase instance")
	
	_singleton.consume_async(purchase.get_item_type(), purchase.get_original_json(), purchase.get_signature())
	
	var consume_finished: Callable = func (is_success: bool, message: String, purchase: Dictionary) -> void:
		finished.call(is_success, message, Purchase.new(purchase))
	
	var consume_failed: Callable = func (message: String) -> void:
		failed.call(message)
	
	if not _singleton.consume_finished.is_connected(consume_finished):
		_singleton.consume_finished.connect(consume_finished, CONNECT_ONE_SHOT)
	
	if not _singleton.consume_failed.is_connected(consume_failed):
		_singleton.consume_failed.connect(consume_failed, CONNECT_ONE_SHOT)


static func close_connection() -> void:
	if not _has_myket():
		return
	
	_singleton.close_connection()
	_singleton.free()
	_singleton = null


static func _has_myket() -> bool:
	return is_instance_valid(_singleton)


static func _has_singleton() -> bool:
	return Engine.has_singleton(_singleton_name)


static func _get_singleton() -> Object:
	return Engine.get_singleton(_singleton_name)

class Product extends RefCounted:

	var _sku: String
	var sku: String:
		get = get_sku
	
	var _type: String
	var type: String:
		get = get_type
	
	var _price: String
	var price: String:
		get = get_price
	
	var _title: String
	var title: String:
		get = get_title
	
	var _description: String
	var description: String:
		get = get_description

	func _init(data: Dictionary) -> void:
		_sku = data.get("sku", "")
		_type = data.get("type", "")
		_price = data.get("price", "")
		_title = data.get("title", "")
		_description = data.get("description", "")


	func get_sku() -> String:
		return _sku
	
	
	func get_type() -> String:
		return _type
	
	
	func get_price() -> String:
		return _price
	
	
	func get_title() -> String:
		return _title
	
	
	func get_description() -> String:
		return _description

class Purchase extends RefCounted:

	var _item_type: String
	var item_type: String:
		get = get_item_type
	
	var _order_id: String
	var order_id: String:
		get = get_order_id
	
	var _sku: String
	var sku: String:
		get = get_sku
	
	var _purchase_time: int
	var purchase_time: int:
		get = get_purchase_time
	
	var _purchase_state: int
	var purchase_state: int:
		get = get_purchase_state
	
	var _developer_payload: String
	var developer_payload: String:
		get = get_developer_payload
	
	var _token: String
	var token: String:
		get = get_token
	
	var _original_json: String
	var original_json: String:
		get = get_original_json
	
	var _package_name: String
	var package_name: String:
		get = get_package_name
	
	var _signature: String
	var signature: String:
		get = get_signature
	

	func _init(data: Dictionary) -> void:
		_item_type = data.get("item_type", "")
		_order_id = data.get("order_id", "")
		_sku = data.get("sku", "")
		_purchase_time = data.get("purchase_time", -1)
		_purchase_state = data.get("purchase_state", -1)
		_developer_payload = data.get("developer_payload", "")
		_token = data.get("token", "")
		_original_json = data.get("original_json", "")
		_package_name = data.get("package_name", "")
		_signature = data.get("signature", "")


	func get_item_type() -> String:
		return _item_type
	
	
	func get_order_id() -> String:
		return _order_id
	
	
	func get_sku() -> String:
		return _sku
	
	
	func get_purchase_time() -> int:
		return _purchase_time
	
	
	func get_purchase_state() -> int:
		return _purchase_state
	
	
	func get_developer_payload() -> String:
		return _developer_payload
	
	
	func get_token() -> String:
		return _token
	
	
	func get_original_json() -> String:
		return _original_json
	
	
	func get_package_name() -> String:
		return _package_name
	
	
	func get_signature() -> String:
		return _signature

class Inventory extends RefCounted:

	var _products: Array[Product]
	var products: Array[Product]:
		get = get_products
	
	var _purchases: Array[Purchase]
	var purchases: Array[Purchase]:
		get = get_purchases

	func _init(data: Dictionary) -> void:
		var products: Dictionary = data.get("products", Dictionary())
		var purchases: Dictionary = data.get("purchases", Dictionary())
		for product: Dictionary in products.values():
			_products.append(Product.new(product))
			
		for purchase: Dictionary in purchases.values():
			_purchases.append(Purchase.new(purchase))


	func get_products() -> Array[Product]:
		return _products


	func get_purchases() -> Array[Purchase]:
		return _purchases


	func has_purchase(sku: String) -> bool:
		for purchase: Purchase in purchases:
			if purchase.sku != sku:
				continue
			
			return true
		
		return false


	func has_product(sku: String) -> bool:
		for product: Product in products:
			if product.sku != sku:
				continue
			
			return true
		
		return false


	func remove_purchase(sku: String) -> void:
		for purchase: Purchase in purchases:
			if purchase.sku != sku:
				continue
			
			_purchases.erase(purchase)


	func remove_product(sku: String) -> void:
		for product: Product in products:
			if product.sku != sku:
				continue
			
			_products.erase(product)

@abstract class Intent extends Object:
	
	static func show_comment(package_name: String = "") -> void:
		if not Myket._has_myket():
			return
		
		Myket._singleton.show_intent_comment(package_name)


	static func show_details(package_name: String = "") -> void:
		if not Myket._has_myket():
			return
		
		Myket._singleton.show_intent_details(package_name)


	static func show_download(package_name: String = "") -> void:
		if not Myket._has_myket():
			return
		
		Myket._singleton.show_intent_download(package_name)


	static func show_developer(package_name: String = "") -> void:
		if not Myket._has_myket():
			return
		
		Myket._singleton.show_intent_developer(package_name)
