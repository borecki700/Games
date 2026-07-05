# actors/player/states/attack_state.gd
class_name AttackState
extends BaseState

var combat: CombatComponent


func setup(owner_node: Node) -> void:
	super.setup(owner_node)
	combat = player.combat


func enter(_data: Dictionary = {}) -> void:
	player.velocity.x = 0.0
	player.velocity.z = 0.0

	# Sygnały PRZED try_attack()
	combat.attack_ended.connect(_on_attack_ended)
	combat.combo_finished.connect(_on_combo_finished)

	if not combat.try_attack():
		_disconnect_signals()
		state_machine.transition_to("IdleState")


func exit() -> void:
	_disconnect_signals()


func physics_update(delta: float) -> void:
	movement.process_gravity(delta)


func update(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		combat.try_attack()


func _on_attack_ended() -> void:
	# ✅ NIE wywołujemy try_attack() tutaj
	# _tick_combo_window w CombatComponent sam zadba o następny cios
	# My tylko sprawdzamy czy wrócić do ruchu
	if not combat.is_attacking and combat._combo_window <= 0.0:
		_return_to_movement()


func _on_combo_finished() -> void:
	_return_to_movement()


func _return_to_movement() -> void:
	if not movement.is_on_floor:
		state_machine.transition_to("FallState")
	elif movement.is_moving:
		state_machine.transition_to("WalkState")
	else:
		state_machine.transition_to("IdleState")


func _disconnect_signals() -> void:
	if combat.attack_ended.is_connected(_on_attack_ended):
		combat.attack_ended.disconnect(_on_attack_ended)
	if combat.combo_finished.is_connected(_on_combo_finished):
		combat.combo_finished.disconnect(_on_combo_finished)
