# actors/enemies/base_enemy/components/enemy_combat_component.gd
class_name EnemyCombatComponent
extends Node

signal attack_finished()

var _data: EnemyData
var _attack_timer: float   = 0.0
var _cooldown_timer: float = 0.0
var is_attacking: bool     = false


func initialize(data: EnemyData) -> void:
	_data = data


func _process(delta: float) -> void:
	if is_attacking:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			is_attacking = false
			attack_finished.emit()

	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta


func can_attack() -> bool:
	return not is_attacking and _cooldown_timer <= 0.0


func start_attack() -> void:
	is_attacking    = true
	_attack_timer   = _data.attack_duration
	_cooldown_timer = _data.attack_cooldown


func get_damage() -> int:
	return _data.damage
