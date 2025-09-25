@tool
extends EditorPlugin

var export_plugin : AndroidExportPlugin

func _enter_tree():
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree():
	remove_export_plugin(export_plugin)
	export_plugin = null


class AndroidExportPlugin extends EditorExportPlugin:

	const BACKUP_PATH: String = "res://addons/myket/.backup"
	const BACKUP_IGNORE_PATH: String = "res://addons/myket/.backup/.gdignore"
	const BACKUP_BUILD_GRADLE_PATH: String = "res://addons/myket/.backup/build.gradle"
	const BUILD_GRADLE_PATH: String = "res://android/build/build.gradle"
	const MANIFEST_PLACEHOLDERS : String = """
        def marketApplicationId = "ir.mservices.market"
        def marketBindAddress = "ir.mservices.market.InAppBillingService.BIND"
        manifestPlaceholders = [marketApplicationId: "${marketApplicationId}",
                marketBindAddress  : "${marketBindAddress}",
                marketPermission   : "${marketApplicationId}.BILLING"]"""
	
	var _plugin_name = "GodotMyket"

	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		if not DirAccess.dir_exists_absolute(BACKUP_PATH):
			DirAccess.make_dir_absolute(BACKUP_PATH)
			DirAccess.copy_absolute(BUILD_GRADLE_PATH, BACKUP_BUILD_GRADLE_PATH)
			FileAccess.open(BACKUP_IGNORE_PATH, FileAccess.WRITE)
		
		DirAccess.copy_absolute(BACKUP_BUILD_GRADLE_PATH, BUILD_GRADLE_PATH)
		var file := FileAccess.open(BUILD_GRADLE_PATH, FileAccess.READ)
		
		var default_config: bool = false
		var lines: Array[String]
		while not file.eof_reached():
			var line := file.get_line()
			if line.contains("defaultConfig"):
				default_config = true
			
			if default_config and line.is_empty():
				lines.push_back(MANIFEST_PLACEHOLDERS)
				default_config = false
			
			lines.push_back(line)
		
		file.close()
		file = FileAccess.open(BUILD_GRADLE_PATH, FileAccess.WRITE)
		while not lines.is_empty():
			file.store_line(lines.pop_front())
		
		file.close()


	func _export_end() -> void:
		DirAccess.copy_absolute(BACKUP_BUILD_GRADLE_PATH, BUILD_GRADLE_PATH)


	func _supports_platform(platform: EditorExportPlatform) -> bool:
		if platform is EditorExportPlatformAndroid:
			return true
		return false


	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		if debug:
			return PackedStringArray(["myket/bin/GodotMyket-debug.aar"])
		else:
			return PackedStringArray(["myket/bin/GodotMyket-release.aar"])


	func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray(["com.github.myketstore:myket-billing-client:1.18"])


	func _get_android_dependencies_maven_repos(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray(["https://jitpack.io"])


	func _get_name():
		return _plugin_name
