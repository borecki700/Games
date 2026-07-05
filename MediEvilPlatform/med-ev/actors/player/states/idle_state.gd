# actors/player/states/idle_state.gd
class_name IdleState
extends BaseState

func enter(_data: Dictionary = {}) -> void:
	animation.play("idle")

func physics_update(delta: float) -> void:
	# Atak ma priorytet nad ruchem
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("AttackState")
		return
	movement.process_gravity(delta)
	movement.process_horizontal_movement(delta)
	
	# Przejście do Jump jeśli bufor skoku był aktywny przy lądowaniu
	if movement.tick_and_consume_jump_buffer(delta):
		state_machine.transition_to("JumpState")
		return
	
	if not movement.is_on_floor:
		state_machine.transition_to("FallState")
		return
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("JumpState")
		return
	
	if movement.is_moving:
		state_machine.transition_to("WalkState")
