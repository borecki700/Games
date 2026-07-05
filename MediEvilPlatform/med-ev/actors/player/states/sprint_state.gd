# actors/player/states/sprint_state.gd
class_name SprintState
extends BaseState

func enter(_data: Dictionary = {}) -> void:    # ← WEWNĄTRZ klasy
	animation.play("run")

func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("AttackState")
		return
	movement.process_gravity(delta)
	movement.process_horizontal_movement(delta)
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("JumpState")
		return
	if not movement.is_on_floor:
		state_machine.transition_to("FallState")
		return
	if not movement.is_sprinting or not movement.is_moving:
		state_machine.transition_to("WalkState")
