# actors/player/components/animation_component.gd
class_name AnimationComponent
extends Node

@export var animation_tree_path: NodePath
@onready var _tree: AnimationTree = get_node(animation_tree_path)

const PLAYBACK_PATH := "parameters/playback"
var _playback: AnimationNodeStateMachinePlayback


func _ready() -> void:
	assert(_tree != null, "AnimationComponent: AnimationTree nie znaleziony!")
	_playback = _tree.get(PLAYBACK_PATH)
	assert(_playback != null, "AnimationComponent: brak playback!")


func play(state_name: String) -> void:
	if _playback.get_current_node() == state_name:
		return
	_playback.travel(state_name)


# ✅ Dla ataków — start() omija wymaganie ścieżek w grafie
# Idealne dla animacji które muszą grać NATYCHMIAST
func force_play(state_name: String) -> void:
	_playback.start(state_name)


func get_current_animation() -> String:
	return _playback.get_current_node()


func is_playing(state_name: String) -> bool:
	return _playback.get_current_node() == state_name


func play_attack(combo_index: int) -> void:
	var anim_name := "attack%d" % (combo_index + 1)
	force_play(anim_name)    # ← force_play zamiast play
