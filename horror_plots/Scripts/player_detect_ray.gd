extends RayCast3D


func _process(delta: float) -> void:
	if is_colliding():
		var hit = get_collider()
		if hit.name == "Player" and get_parent().chasing == false:
			get_parent().chasing = true
			get_parent().speed = 5.0
