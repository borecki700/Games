extends Area2D

@export var speed := 400
@export var direction := Vector2.RIGHT
@export var lifetime := 1.0 
@export var max_distance := 1000

var _elapsed_time := 0.0

func _ready():
	$CollisionShape2D.disabled = false
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta
	_elapsed_time += delta
	if _elapsed_time > lifetime:
		queue_free()

func _on_body_entered(body):
	# Tylko wrogowie — np. sprawdzaj grupę
	print("Kolizja z: ", body.name)
	if body.is_in_group("enemies"):
		body.take_damage()  # jeśli ma taką metodę
		queue_free()
	else:
		# np. kolizja ze ścianą
		queue_free()
