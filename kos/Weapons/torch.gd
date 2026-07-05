extends RigidBody2D

@export var fire_duration := 3.0
@export var damage_interval := 0.5
@export var max_torches := 2
@export var direction := Vector2.ZERO

var has_landed := false
var active_enemies := []

@onready var fire_timer := $Timer
@onready var damage_area := $Area2D

func _ready():
	gravity_scale = 1.0
	fire_timer.wait_time = fire_duration
	fire_timer.one_shot = true
	damage_area.connect("body_entered", _on_body_entered)
	damage_area.connect("body_exited", _on_body_exited)

func _integrate_forces(state):
	if not has_landed and linear_velocity.y == 0:
		has_landed = true
		fire_timer.start()
		$Sprite2D.modulate = Color(1, 0.5, 0.2) # zapalenie ognia

func _process(delta):
	if has_landed:
		for enemy in active_enemies:
			if enemy.has_method("take_damage"):
				enemy.take_damage()

func _on_body_entered(body):
	if has_landed and body.is_in_group("enemies"):
		active_enemies.append(body)

func _on_body_exited(body):
	if body in active_enemies:
		active_enemies.erase(body)

func _on_Timer_timeout():
	queue_free()
