# actors/enemies/base_enemy/components/navigation_component.gd
class_name NavigationComponent
extends Node

var _agent: NavigationAgent3D
var _enemy: CharacterBody3D
var _data: EnemyData


func initialize(enemy: CharacterBody3D, agent: NavigationAgent3D, data: EnemyData) -> void:
	_enemy = enemy
	_agent = agent
	_data  = data

	_agent.path_desired_distance   = 0.5   # ← przywróć 0.5
	_agent.target_desired_distance = 1.0   # ← większa tolerancja końcowa
	_agent.path_max_distance       = 2.0


func move_toward_target(delta: float, speed: float) -> void:
	if _agent.is_navigation_finished():
		_enemy.velocity.x = move_toward(_enemy.velocity.x, 0.0, 20.0 * delta)
		_enemy.velocity.z = move_toward(_enemy.velocity.z, 0.0, 20.0 * delta)
		return

	var next_pos  := _agent.get_next_path_position()
	var direction := (_enemy.global_position - next_pos)
	direction.y   = 0.0
	direction      = direction.normalized()

	_enemy.velocity.x = move_toward(
		_enemy.velocity.x, -direction.x * speed, 20.0 * delta)
	_enemy.velocity.z = move_toward(
		_enemy.velocity.z, -direction.z * speed, 20.0 * delta)

	if direction != Vector3.ZERO:
		var target_angle  := atan2(-direction.x, -direction.z)
		_enemy.rotation.y  = lerp_angle(
			_enemy.rotation.y, target_angle, _data.rotation_speed * delta)


func set_target_position(pos: Vector3) -> void:
	_agent.target_position = pos


func is_navigation_finished() -> bool:
	return _agent.is_navigation_finished()


func apply_gravity(delta: float) -> void:
	if not _enemy.is_on_floor():
		_enemy.velocity.y -= 22.0 * delta
	else:
		if _enemy.velocity.y < 0.0:
			_enemy.velocity.y = -0.5


# ✅ NOWE — zatrzymuje agenta i zeruje velocity poziome
func stop() -> void:
	# Ustawienie celu na aktualną pozycję = agent uznaje cel za osiągnięty
	_agent.target_position = _enemy.global_position
	_enemy.velocity.x      = 0.0
	_enemy.velocity.z      = 0.0
