# actors/player/states/fall_state.gd
class_name FallState
extends BaseState

func enter(_data: Dictionary = {}) -> void:
	animation.play("fall")

func physics_update(delta: float) -> void:
	movement.process_gravity(delta)
	movement.process_horizontal_movement(delta)

	if Input.is_action_just_pressed("jump"):
		movement.buffer_jump()

	if movement.is_on_floor:
		EventBus.player_landed.emit()
		movement.stop_horizontal()

		if movement.tick_and_consume_jump_buffer(delta):
			state_machine.transition_to("JumpState")
		elif movement.is_moving:
			state_machine.transition_to("WalkState")
		else:
			state_machine.transition_to("IdleState")
	else:
		movement.tick_and_consume_jump_buffer(delta)
