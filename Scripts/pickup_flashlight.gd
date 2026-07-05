extends StaticBody3D

var flashlight 

func _ready() -> void:
	flashlight = get_node("/root/" + get_tree().current_scene.name + "/Player/Head/Flashlight")

func interact():
	get_node('/root/' + get_tree().current_scene.name + "/Sounds/pick_up").play()
	flashlight.picked_up = true
	queue_free()
