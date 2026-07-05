# shared/state_machine/state_machine.gd
class_name StateMachine
extends Node

var current_state: BaseState
var states: Dictionary = {}   # String → BaseState

signal state_changed(new_state_name: String)


func _ready() -> void:
	# Zbieramy wszystkie dzieci będące stanami
	for child in get_children():
		if child is BaseState:
			states[child.name] = child


func start(initial_state_name: String) -> void:
	assert(states.has(initial_state_name), 
		"StateMachine: brak stanu '%s'" % initial_state_name)
	
	# Dajemy czas ownerowi na _ready()
	await owner.ready
	
	# Inicjalizujemy każdy stan — przekazujemy referencję do ownera
	for state: BaseState in states.values():
		state.setup(owner)
	
	_enter_state(states[initial_state_name])


func transition_to(state_name: String, data: Dictionary = {}) -> void:
	if not states.has(state_name):
		push_error("StateMachine: nieznany stan '%s'" % state_name)
		return
	
	if current_state != null:
		current_state.exit()
	
	_enter_state(states[state_name], data)


func _enter_state(state: BaseState, data: Dictionary = {}) -> void:
	current_state = state
	current_state.enter(data)
	state_changed.emit(current_state.name)
	EventBus.player_state_changed.emit(current_state.name)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
