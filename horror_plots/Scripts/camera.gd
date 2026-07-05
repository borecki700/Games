extends Node3D

var sens = 0.005
#DLA GRY NORMALNEJ movable = false dla testu movable = true
var movable = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and movable == true:
		get_parent().rotate_y(-event.relative.x * sens)
		rotate_x(-event.relative.y * sens)
		rotation.x = clamp(rotation.x, deg_to_rad(-90),deg_to_rad(90))
