@tool
extends EditorPlugin

const MENU_NAME: String = "Apply Myket Manifest Placeholders..."
const CURRENT_PLACEHOLDERS: String = (
	"        manifestPlaceholders = [\n"
	+ "            godotEditorVersion: getGodotEditorVersion(),\n"
	+ "            godotRenderingMethod: getGodotRenderingMethod()\n"
	+ "        ]"
)
const MANIFEST_PLACEHOLDERS: String = (
	CURRENT_PLACEHOLDERS
	+ "\n\tdef marketApplicationId = \"ir.mservices.market\"\n" \
	+ "\tdef marketBindAddress = \"ir.mservices.market.InAppBillingService.BIND\"\n"
	+ "\tmanifestPlaceholders += [marketApplicationId: \"${marketApplicationId}\",\n"
	+ "\t\tmarketBindAddress  : \"${marketBindAddress}\",\n"
	+ "\t\tmarketPermission   : \"${marketApplicationId}.BILLING\"]"
)

var export_plugin : AndroidExportPlugin

func _enter_tree():
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)
	add_tool_menu_item(MENU_NAME, _add_manifest_placeholders)

func _exit_tree():
	remove_tool_menu_item(MENU_NAME)
	remove_export_plugin(export_plugin)
	export_plugin = null

func _has_manifest_placeholders() -> bool:
	var file: FileAccess = FileAccess.open("res://android/build/build.gradle",FileAccess.READ_WRITE)
	var text: String = file.get_as_text()
	if text.contains("marketApplicationId"):
		return true
	return false

func _add_manifest_placeholders() -> void:
	if not DirAccess.dir_exists_absolute("res://android"): return
	if _has_manifest_placeholders(): return
	var file: FileAccess = FileAccess.open("res://android/build/build.gradle",FileAccess.READ_WRITE)
	var text: String = file.get_as_text()
	print(text.find(CURRENT_PLACEHOLDERS))
	text = text.replace(CURRENT_PLACEHOLDERS, MANIFEST_PLACEHOLDERS)
	file.store_string(text)

class AndroidExportPlugin extends EditorExportPlugin:
	var _plugin_name = "GodotMyket"

	func _supports_platform(platform):
		if platform is EditorExportPlatformAndroid:
			return true
		return false

	func _get_android_libraries(platform, debug):
		if debug:
			return PackedStringArray(["myket/bin/GodotMyket-debug.aar"])
		else:
			return PackedStringArray(["myket/bin/GodotMyket-release.aar"])

	func _get_android_dependencies(platform, debug):
		return PackedStringArray(["com.github.myketstore:myket-billing-client:1.6"])

	func _get_android_dependencies_maven_repos(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray(["https://jitpack.io"])

	func _get_name():
		return _plugin_name
