extends CharacterBody2D

@export var attack_range := 300
@export var attack_cooldown := 2
@export var speed := 20
@export var patrol_distance := 100.0
@export var projectile_scene: PackedScene
@export var hp := 2


@onready var player :=  get_node("/root/TestLevel/Player")# dostosuj ścieżkę do gracza
@onready var marker := $Marker2D
@onready var attack_timer := $Timer

var direction := 1
var start_position := Vector2.ZERO

func _ready():
	start_position = global_position


func _physics_process(delta):
	if not player:
		return
	var dir_to_player = player.global_position - global_position
	var distance = dir_to_player.length()
	if distance <= attack_range:
		velocity.x = 0 
		$AnimatedSprite2D.flip_h = dir_to_player.x < 0
	else:
		patrol()
		$AnimatedSprite2D.flip_h = direction < 0
	move_and_slide()

func shoot_projectile():
	var bullet = projectile_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = marker.global_position
	bullet.direction = (player.global_position - global_position).normalized()

func _on_timer_timeout():
	if not player:
		return
	var dir = player.global_position - global_position
	if dir.length() <= attack_range:
		shoot_projectile()


func patrol():
	velocity.x = direction * speed
	var walked = global_position.distance_to(start_position)
	if walked >= patrol_distance:
		direction *= -1
		start_position = global_position

func take_damage():
	hp -= 1
	if hp <= 0:
		Ui.add_points(200)
		queue_free()
