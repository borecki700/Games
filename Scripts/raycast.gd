extends RayCast3D

var interact_txt

func _ready() -> void:
	interact_txt = get_node("/root/" + get_tree().current_scene.name + "/UI/interact_txt")

func _process(delta: float) -> void:
	if is_colliding():
		var hit = get_collider()
		if hit.has_method("interact"):
			interact_txt.visible = true
			if Input.is_action_just_pressed("interact"):
				hit.interact()
		else:
			interact_txt.visible = false
	else:
		interact_txt.visible = false
	
