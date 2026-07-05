extends StaticBody3D


func interact():
	get_node('/root/' + get_tree().current_scene.name + "/Sounds/key_get").play()
	queue_free()
