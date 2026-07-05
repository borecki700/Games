# actors/enemies/skeleton/states/enemy_patrol_state.gd
class_name EnemyPatrolState
extends BaseEnemyState

var _stuck_timer: float     = 0.0
# ✅ Bufor czasowy — czekamy aż NavigationAgent przetworzy ścieżkę
var _path_ready_timer: float = 0.0
const PATH_READY_DELAY       := 0.5  # sekundy zanim zaczniemy sprawdzać cel


func enter(_d: Dictionary = {}) -> void:
	_stuck_timer      = 0.0
	_path_ready_timer = 0.0
	_pick_new_patrol_point()


func physics_update(delta: float) -> void:
	navigation.apply_gravity(delta)

	# Wykrycie gracza zawsze aktywne
	if is_player_in_range(data.detection_range):
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		state_machine.transition_to("EnemyChaseState")
		return

	# ✅ Odczekaj zanim NavigationAgent przetworzy ścieżkę
	_path_ready_timer += delta
	if _path_ready_timer < PATH_READY_DELAY:
		return

	# Dotarł do celu
	if navigation.is_navigation_finished():
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		state_machine.transition_to("EnemyIdleState")
		return

	# Normalny ruch
	navigation.move_toward_target(delta, data.patrol_speed)

	# Zabezpieczenie przed utknięciem
	_stuck_timer += delta
	if _stuck_timer > 8.0:
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		state_machine.transition_to("EnemyIdleState")


func _pick_new_patrol_point() -> void:
	var skeleton := enemy as Skeleton
	var angle    := randf() * TAU
	var radius   := randf_range(2.0, data.patrol_radius)
	var offset   := Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
	navigation.set_target_position(skeleton.spawn_position + offset)
	_stuck_timer = 0.0
