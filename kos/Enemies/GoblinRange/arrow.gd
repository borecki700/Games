extends Area2D

@export var lifetime := 2.0 
@export var speed := 200
var direction := Vector2.ZERO
var _elapsed_time := 0.0
func _ready():
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta
	_elapsed_time += delta
	if _elapsed_time > lifetime:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage() # musisz mieć metodę take_damage() u gracza
		queue_free()
	elif not body.is_in_group("enemies"):
		queue_free()
