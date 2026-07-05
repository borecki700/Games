# actors/enemies/skeleton/states/enemy_idle_state.gd
class_name EnemyIdleState
extends BaseEnemyState

var _wait_timer: float = 0.0


func enter(_d: Dictionary = {}) -> void:
	_wait_timer = data.patrol_wait_time
	enemy.velocity = Vector3.ZERO


func physics_update(delta: float) -> void:
	navigation.apply_gravity(delta)
	_wait_timer -= delta

	# Gracz wykryty — natychmiast pościg
	if is_player_in_range(data.detection_range):
		state_machine.transition_to("EnemyChaseState")
		return

	# Odczekano — idź na patrol
	if _wait_timer <= 0.0:
		state_machine.transition_to("EnemyPatrolState")
