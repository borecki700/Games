# ui/hud/lock_on_marker/lock_on_marker.gd
class_name LockOnMarker
extends Control

@onready var _icon: Label = $MarkerIcon

var _target: Node3D  = null
var _camera: Camera3D = null

# Offset nad głową wroga
const WORLD_OFFSET := Vector3(0.0, 4, 0.0)


func _ready() -> void:
	visible = false

	EventBus.lock_on_acquired.connect(_on_acquired)
	EventBus.lock_on_released.connect(_on_released)
	EventBus.lock_on_target_died.connect(_on_released)

	await get_tree().process_frame
	_camera = get_viewport().get_camera_3d()


func _process(_delta: float) -> void:
	if not visible or _target == null or _camera == null:
		return

	var world_pos  := _target.global_position + WORLD_OFFSET
	var screen_pos := _camera.unproject_position(world_pos)

	# Wyśrodkuj marker
	global_position = screen_pos - size * 0.5

	# Ukryj gdy za kamerą
	visible = _camera.is_position_in_frustum(world_pos)


func _on_acquired(target: Node3D) -> void:
	_target = target
	visible = true
	# Animacja pojawienia się
	var tween := create_tween()
	_icon.modulate.a = 0.0
	tween.tween_property(_icon, "modulate:a", 1.0, 0.2)


func _on_released() -> void:
	var tween := create_tween()
	tween.tween_property(_icon, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): visible = false; _target = null)
