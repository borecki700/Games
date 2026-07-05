extends CharacterBody2D

class_name Player


const BULLET = preload("uid://6ygdn56sy13u")
@onready var pistol: Marker2D = $Pistol

const SPEED = 300.0
@onready var enemy_detect: Area2D = $EnemyDetect

func _physics_process(delta: float) -> void:
	#Move
	var direction := Input.get_vector("A","D","W","S").normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	look_at(get_global_mouse_position())


func _process(delta: float) -> void:
	shoot()


func _on_enemy_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		queue_free()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game_over.tscn")

func shoot():
	if Input.is_action_just_pressed("X"):
		var new_bullet = BULLET.instantiate()
		new_bullet.global_position = pistol.global_position
		new_bullet.global_rotation = pistol.global_rotation
		get_parent().add_child(new_bullet)
		
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0.8, 1.2), 0.1)
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
		
