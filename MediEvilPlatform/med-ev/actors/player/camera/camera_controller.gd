# actors/player/camera/camera_controller.gd
class_name CameraController
extends Node3D

@export_group("Sensitivity")
@export var mouse_sensitivity: float    = 0.003
@export var gamepad_sensitivity: float  = 2.5

@export_group("Pitch Limits")
@export var min_pitch_deg: float = -50.0
@export var max_pitch_deg: float =  70.0

@export_group("Spring Arm")
@export var default_length: float   = 6.0
@export var sprint_length: float    = 7.5
@export var lock_on_length: float   = 5.0   # bliżej przy lock-on
@export var length_smoothing: float = 8.0

@export_group("Lock-On")
@export var lock_on_rotation_speed: float = 5.0   # płynność obrotu w lock-on
@export var lock_on_pitch: float          = -15.0  # kąt kamery przy lock-on
@export var follow_offset: Vector3        = Vector3(0.0, 1.5, 0.0)

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D        = $SpringArm3D/Camera3D

var _pitch_rad: float = deg_to_rad(-15.0)
var _lock_on_target: Node3D = null
var _is_locked: bool        = false


func _ready() -> void:
	Input.mouse_mode         = Input.MOUSE_MODE_CAPTURED
	spring_arm.spring_length = default_length
	spring_arm.rotation.x   = _pitch_rad
	set_as_top_level(true)

	# Podłącz sygnały lock-on
	EventBus.lock_on_acquired.connect(_on_lock_on_acquired)
	EventBus.lock_on_released.connect(_on_lock_on_released)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED \
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE \
			else Input.MOUSE_MODE_VISIBLE

	# Mysz działa tylko gdy NIE jesteśmy w lock-on
	if event is InputEventMouseMotion \
	and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED \
	and not _is_locked:
		_rotate_camera(
			-event.relative.y * mouse_sensitivity,
			-event.relative.x * mouse_sensitivity
		)


func _process(delta: float) -> void:
	_follow_player()

	if _is_locked and _lock_on_target != null:
		_process_lock_on_camera(delta)
	else:
		_handle_gamepad_camera(delta)

	_update_spring_length(delta)


func _follow_player() -> void:
	global_position = get_parent().global_position + follow_offset


# ─── Tryb normalny ────────────────────────────────────────────────────────────

func _rotate_camera(pitch_delta: float, yaw_delta: float) -> void:
	rotate_y(yaw_delta)
	_pitch_rad = clampf(
		_pitch_rad + pitch_delta,
		deg_to_rad(min_pitch_deg),
		deg_to_rad(max_pitch_deg)
	)
	spring_arm.rotation.x = _pitch_rad


func _handle_gamepad_camera(delta: float) -> void:
	var stick := Input.get_vector(
		"camera_left", "camera_right", "camera_up", "camera_down")
	if stick != Vector2.ZERO:
		_rotate_camera(
			-stick.y * gamepad_sensitivity * delta,
			-stick.x * gamepad_sensitivity * delta
		)


# ─── Tryb Lock-On ─────────────────────────────────────────────────────────────

func _process_lock_on_camera(delta: float) -> void:
	# Kierunek od kamery do celu
	var target_pos    := _lock_on_target.global_position + Vector3(0, 1.0, 0)
	var camera_pos    := global_position
	var direction     := (target_pos - camera_pos).normalized()

	# Oblicz docelowy kąt Yaw (poziomy)
	var target_yaw    := atan2(-direction.x, -direction.z)

	# Płynna rotacja Yaw
	var current_yaw   := rotation.y
	rotation.y         = lerp_angle(current_yaw, target_yaw,
		lock_on_rotation_speed * delta)

	# Pitch — delikatnie w dół w stronę wroga
	var target_pitch  := deg_to_rad(lock_on_pitch)
	_pitch_rad         = lerpf(_pitch_rad, target_pitch,
		lock_on_rotation_speed * delta)
	spring_arm.rotation.x = _pitch_rad


func _update_spring_length(delta: float) -> void:
	var target_length: float
	if _is_locked:
		target_length = lock_on_length
	elif Input.is_action_pressed("sprint") \
	and Input.get_vector("move_left","move_right","move_forward","move_backward") != Vector2.ZERO:
		target_length = sprint_length
	else:
		target_length = default_length

	spring_arm.spring_length = lerpf(
		spring_arm.spring_length, target_length, length_smoothing * delta)


func _on_lock_on_acquired(target: Node3D) -> void:
	_lock_on_target = target
	_is_locked      = true


func _on_lock_on_released() -> void:
	_lock_on_target = null
	_is_locked      = false


func get_horizontal_basis() -> Basis:
	return global_transform.basis
