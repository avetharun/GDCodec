@tool
extends EditorPlugin


func _enable_plugin() -> void:
	add_autoload_singleton("Packets", (get_script() as Script).resource_path.get_base_dir() + "/packets.gd")
	pass


func _disable_plugin() -> void:
	remove_autoload_singleton("Packets")
	pass
