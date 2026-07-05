extends StaticBody3D

var interactable = true
var opened = false

func enemy_interact():
	if opened == false and get_parent().get_parent().locked == false:
		opened = true
		$open.play()
		interactable = false
		$AnimationPlayer.play("open")
		await get_tree().create_timer(1.0 , false).timeout
		interactable = true

func interact():
	if get_parent().get_parent().locked == true and get_parent().get_parent().key == null:
		get_parent().get_parent().locked = false
	if interactable == true and get_parent().get_parent().locked == false:
		interactable = false
		opened = !opened
		if opened == false:
			$AnimationPlayer.play("close")
			$close.play()
		else :
			$AnimationPlayer.play("open")
			$open.play()
		await get_tree().create_timer(1.0,false).timeout
		interactable = true
	if interactable == true and get_parent().get_parent().locked == true:
		interactable = false
		$AnimationPlayer.play("locked")
		$closed.play()
		await get_tree().create_timer(0.4,false).timeout
		interactable = true
