extends Area3D

@export var monster : CharacterBody3D
var token = 0 

func spawn_monster(body):
	if body == get_node("/root/" + get_tree().current_scene.name + "/Player") and token == 0:
		monster.visible = true
		token = 1
