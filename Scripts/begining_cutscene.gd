extends Node3D


func _ready() -> void:
	$anim_cutscene_cam.play("begining")
	$cutscene_cam.current = true
	await get_tree().create_timer(8.0,false).timeout
	get_node("/root/" + get_tree().current_scene.name +"/Player").movable = true
	get_node("/root/" + get_tree().current_scene.name +"/Player/Head/Camera3D").current = true
	get_node("/root/" + get_tree().current_scene.name +"/Player/Head").movable = true
	$cutscene_cam.current = false
	queue_free()
