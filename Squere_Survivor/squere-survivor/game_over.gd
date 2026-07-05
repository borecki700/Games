extends Control

@onready var score_label: Label = $ScoreLabel

func _ready() -> void:
	score_label.text = "Global Score: " + str(Global.score)

func _on_restart_pressed() -> void:
	Global.score = 0
	Global.harder = 0
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/main.tscn")


func _on_menu_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/menu.tscn")
