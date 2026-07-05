extends StaticBody3D


func interact():
	GameManager.star_collcted += 1
	queue_free()
