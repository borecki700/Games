extends CanvasLayer

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/test_level.tscn")
	Ui._ready()

func _on_exit_pressed() -> void:
	get_tree().quit()
