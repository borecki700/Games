# actors/enemies/skeleton/states/enemy_chase_state.gd
class_name EnemyChaseState
extends BaseEnemyState

var _update_path_timer: float = 0.0
const PATH_UPDATE_INTERVAL    := 0.15


func physics_update(delta: float) -> void:
	navigation.apply_gravity(delta)

	_update_path_timer -= delta
	if _update_path_timer <= 0.0:
		_update_path_timer = PATH_UPDATE_INTERVAL
		if player != null:
			navigation.set_target_position(player.global_position)

	navigation.move_toward_target(delta, data.chase_speed)

	if is_player_in_range(data.attack_range):
		state_machine.transition_to("EnemyAttackState")
		return

	if distance_to_player() > data.lose_target_range:
		state_machine.transition_to("EnemyPatrolState")
