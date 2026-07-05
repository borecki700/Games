# shared/state_machine/base_state.gd
class_name BaseState
extends Node

var player: Player
var movement: MovementComponent
var animation: AnimationComponent
var state_machine: StateMachine
# combat celowo NIE jest tutaj — tylko AttackState go używa


func setup(owner_node: Node) -> void:
	player        = owner_node as Player
	movement      = player.movement
	animation     = player.animation
	state_machine = get_parent() as StateMachine

func enter(_data: Dictionary = {}) -> void: pass
func exit() -> void: pass
func update(_delta: float) -> void: pass
func physics_update(_delta: float) -> void: pass
