# actors/player/components/movement_component.gd
class_name MovementComponent
extends Node

var _player: CharacterBody3D
var _stats: PlayerStats
var _camera: CameraController

var _coyote_timer: float      = 0.0
var _jump_buffer_timer: float = 0.0
var _is_sprinting: bool       = false

# Ustawiane przez Player gdy lock-on aktywny
var lock_on_target: Node3D = null

var is_on_floor: bool:
	get: return _player.is_on_floor()

var current_horizontal_speed: float:
	get: return Vector2(_player.velocity.x, _player.velocity.z).length()

var is_moving: bool:
	get: return current_horizontal_speed > 0.1

var is_sprinting: bool:
	get: return _is_sprinting


func initialize(player: CharacterBody3D, stats: PlayerStats,
				camera: CameraController) -> void:
	_player = player
	_stats  = stats
	_camera = camera


func process_horizontal_movement(delta: float,
								allow_sprint: bool = true) -> void:
	_is_sprinting = allow_sprint \
		and Input.is_action_pressed("sprint") \
		and is_moving

	var speed     := _stats.sprint_speed if _is_sprinting else _stats.walk_speed
	var direction := _get_movement_direction()

	if direction != Vector3.ZERO:
		_player.velocity.x = move_toward(
			_player.velocity.x, direction.x * speed,
			_stats.acceleration * delta)
		_player.velocity.z = move_toward(
			_player.velocity.z, direction.z * speed,
			_stats.acceleration * delta)
		_apply_rotation(direction, delta)
	else:
		_player.velocity.x = move_toward(
			_player.velocity.x, 0.0, _stats.deceleration * delta)
		_player.velocity.z = move_toward(
			_player.velocity.z, 0.0, _stats.deceleration * delta)

		# ✅ Nawet stojąc — w lock-on obracaj się w stronę wroga
		if _should_face_target():
			_rotate_toward_lock_on_target(delta)


func process_gravity(delta: float) -> void:
	if _player.is_on_floor():
		_coyote_timer = _stats.coyote_time
		if _player.velocity.y < 0.0:
			_player.velocity.y = -0.5
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)
		var multiplier := _stats.fall_gravity_multiplier \
			if _player.velocity.y < 0.0 else 1.0
		_player.velocity.y -= _stats.gravity * multiplier * delta


func try_jump() -> bool:
	if _coyote_timer > 0.0:
		_player.velocity.y = _stats.jump_force
		_coyote_timer      = 0.0
		return true
	return false


func buffer_jump() -> void:
	if _jump_buffer_timer <= 0.0:
		_jump_buffer_timer = _stats.jump_buffer_time


func tick_and_consume_jump_buffer(delta: float) -> bool:
	_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)
	if _jump_buffer_timer > 0.0 and _player.is_on_floor():
		_jump_buffer_timer = 0.0
		return true
	return false


func stop_horizontal() -> void:
	_player.velocity.x = 0.0
	_player.velocity.z = 0.0


func apply_landing_friction(delta: float) -> void:
	var friction := _stats.deceleration * 3.0
	_player.velocity.x = move_toward(_player.velocity.x, 0.0, friction * delta)
	_player.velocity.z = move_toward(_player.velocity.z, 0.0, friction * delta)


# ─── Prywatne ─────────────────────────────────────────────────────────────────

func _get_movement_direction() -> Vector3:
	# ✅ Strafe tylko w lock-on + chodzenie (nie sprint, nie powietrze)
	if _should_strafe():
		return _get_strafe_direction()
	return _get_camera_relative_direction()


func _should_strafe() -> bool:
	## Strafe aktywny gdy:
	## - lock-on włączony
	## - gracz NIE spryntuje
	## - gracz NA ziemi
	return lock_on_target != null \
		and not _is_sprinting \
		and _player.is_on_floor()


func _should_face_target() -> bool:
	## Obracaj w stronę celu gdy stoisz w lock-on na ziemi
	return lock_on_target != null and _player.is_on_floor()


func _get_strafe_direction() -> Vector3:
	var input := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward")
	if input == Vector2.ZERO:
		return Vector3.ZERO

	var to_target := (lock_on_target.global_position \
		- _player.global_position)
	to_target.y = 0.0
	if to_target == Vector3.ZERO:
		return Vector3.ZERO
	to_target = to_target.normalized()

	var right := to_target.cross(Vector3.UP).normalized()
	return (to_target * -input.y + right * input.x).normalized()


func _get_camera_relative_direction() -> Vector3:
	var input := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward")
	if input == Vector2.ZERO:
		return Vector3.ZERO

	var cam_basis := _camera.get_horizontal_basis()
	var forward   := -cam_basis.z
	var right     :=  cam_basis.x
	forward.y      = 0.0
	right.y        = 0.0
	return (forward * -input.y + right * input.x).normalized()


func _apply_rotation(direction: Vector3, delta: float) -> void:
	if _should_face_target():
		# ✅ Sprint w lock-on — obróć w kierunku RUCHU nie celu
		if _is_sprinting:
			_rotate_toward_direction(direction, delta)
		else:
			_rotate_toward_lock_on_target(delta)
	else:
		_rotate_toward_direction(direction, delta)


func _rotate_toward_lock_on_target(delta: float) -> void:
	var to_target := (lock_on_target.global_position \
		- _player.global_position)
	to_target.y = 0.0
	if to_target == Vector3.ZERO:
		return
	var target_angle   := atan2(to_target.x, to_target.z)
	_player.rotation.y  = lerp_angle(
		_player.rotation.y, target_angle, _stats.rotation_speed * delta)


func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	var target_angle   := atan2(direction.x, direction.z)
	_player.rotation.y  = lerp_angle(
		_player.rotation.y, target_angle, _stats.rotation_speed * delta)
