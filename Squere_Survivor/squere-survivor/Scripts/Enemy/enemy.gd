extends CharacterBody2D

class_name Enemy
@export var speed:= 150.0
@export var health:int = 1
@export var points_value:int =1

@onready var player = get_tree().root.find_child("Player", true, false)


func _physics_process(delta: float) -> void:
	if player:
		var direction: Vector2 = global_position.direction_to(player.global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amount :int):
	health -= amount
	var tween = create_tween()
	tween.tween_property(self, "scale" , Vector2(1.2,0.6) , 0.1)
	tween.tween_property(self, "scale" , Vector2(1,1) , 0.1)
	if health <=0:
		die()

func die():
	queue_free()
	Global.add_score(points_value)
