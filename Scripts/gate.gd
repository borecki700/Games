extends Node3D


func _ready() -> void:
	GameManager.all_star_collcted.connect(open_gate)


func open_gate():
	$AnimationPlayer.play("open_gate")
