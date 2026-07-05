extends CharacterBody2D

@export var speed := 40
@export var patrol_distance := 100.0
@export var hp := 2

var direction := 1
var start_position := Vector2.ZERO

func _ready():
	start_position = global_position

func _physics_process(delta):
	velocity.x = direction * speed
	move_and_slide()
	$AnimatedSprite2D.play("patrol")
	var walked = global_position.distance_to(start_position)
	if walked >= patrol_distance:
		direction *= -1
		start_position = global_position
		$AnimatedSprite2D.flip_h = direction < 0

func take_damage():
	hp -= 1
	$AnimatedSprite2D.play("hit")
	if hp <= 0:
		$AnimatedSprite2D.play("death")
		Ui.add_points(100)
		queue_free()
