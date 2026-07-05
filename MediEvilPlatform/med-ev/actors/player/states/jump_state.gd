# actors/player/states/jump_state.gd
class_name JumpState
extends BaseState

func enter(_data: Dictionary = {}) -> void:
	animation.play("jump")
	if not movement.try_jump():
		movement.buffer_jump()
		state_machine.transition_to("FallState")

func physics_update(delta: float) -> void:
	movement.process_gravity(delta)
	movement.process_horizontal_movement(delta)
	
	# Szczyt skoku — przechodzimy do FallState
	if player.velocity.y <= 0.0:
		state_machine.transition_to("FallState")
