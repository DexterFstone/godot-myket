@icon("res://addons/myket/icon.svg")
class_name Myket
extends Node

signal connection_succeed
signal connection_failed(message: String)
signal query_inventory_finished(is_success: bool, message: String, inventory: Inventory)
signal query_inventory_failed(message: String)
signal iab_purchase_finished(is_success: bool, message: String, purchase: Purchase)
signal iab_purchase_failed(message: String)
signal consume_finished(is_success: bool, message: String, purchase: Purchase)
signal consume_failed(message: String)

@export var public_key: String

static var _plugin: JNISingleton
static var _plugin_name: String = "GodotMyket"

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

static func _has_myket() -> bool:
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

class Intent extends RefCounted:
	
	static func show_comment(package_name: String = "") -> void:
		if not Myket._has_myket(): return
		Myket._plugin.show_intent_comment(package_name)

	static func show_details(package_name: String = "") -> void:
		if not Myket._has_myket(): return
		Myket._plugin.show_intent_details(package_name)

	static func show_download(package_name: String = "") -> void:
		if not Myket._has_myket(): return
		Myket._plugin.show_intent_download(package_name)

	static func show_developer(package_name: String = "") -> void:
		if not Myket._has_myket(): return
		Myket._plugin.show_intent_developer(package_name)
