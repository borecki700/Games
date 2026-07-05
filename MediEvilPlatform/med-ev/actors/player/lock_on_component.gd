# actors/player/components/lock_on_component.gd
class_name LockOnComponent
extends Node

signal target_acquired(target: Node3D)
signal target_released()

# Maksymalny zasięg lock-on
@export var max_range: float = 15.0

var current_target: Node3D = null
var _camera: Camera3D
var _player: Player
var _is_locked: bool = false

var is_locked: bool:
	get: return _is_locked and current_target != null


func initialize(player: Player, camera: Camera3D) -> void:
	_player = player
	_camera = camera

	# Gdy wróg umiera — automatycznie zwolnij cel
	EventBus.enemy_died.connect(_on_enemy_died)


func toggle_lock_on() -> void:
	if _is_locked:
		release_target()
	else:
		_try_acquire_target()


func release_target() -> void:
	current_target = null
	_is_locked     = false
	target_released.emit()
	EventBus.lock_on_released.emit()


# ─── Logika wyboru celu ───────────────────────────────────────────────────────

func _try_acquire_target() -> void:
	var best_target := _find_best_target()

	if best_target == null:
		return

	current_target = best_target
	_is_locked     = true
	target_acquired.emit(current_target)
	EventBus.lock_on_acquired.emit(current_target)


func _find_best_target() -> Node3D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var screen_center := get_viewport().get_visible_rect().size * 0.5
	var best_target: Node3D   = null
	var best_score: float     = INF  # mniejszy = lepszy (bliżej środka ekranu)

	for enemy in enemies:
		var enemy_node := enemy as Node3D
		if enemy_node == null:
			continue

		# Sprawdź zasięg
		var distance := _player.global_position.distance_to(
			enemy_node.global_position)
		if distance > max_range:
			continue

		# Sprawdź czy wróg jest przed kamerą
		if not _camera.is_position_in_frustum(enemy_node.global_position):
			continue

		# Przelicz pozycję wroga na ekran
		var screen_pos := _camera.unproject_position(enemy_node.global_position)

		# Score = odległość od środka ekranu
		var screen_dist := screen_pos.distance_to(screen_center)

		if screen_dist < best_score:
			best_score  = screen_dist
			best_target = enemy_node

	return best_target


# ─── Utrata celu ─────────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	if not _is_locked or current_target == null:
		return

	# Cel za daleko — zwolnij automatycznie
	var dist := _player.global_position.distance_to(
		current_target.global_position)
	if dist > max_range * 1.3:  # 30% margines zanim zwolni
		release_target()
		return

	# Cel poza frustum przez chwilę — też zwolnij
	if not _camera.is_position_in_frustum(current_target.global_position):
		release_target()


func _on_enemy_died(enemy: Node3D) -> void:
	if enemy == current_target:
		release_target()
		EventBus.lock_on_target_died.emit()
