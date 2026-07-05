extends Area2D

var speed :int = 1000
const MAX_DISTANCE :int = 500
@onready var start_position = global_position
@onready var laser_sound: AudioStreamPlayer2D = $LaserSound

func _ready() -> void:
	laser_sound.play()

func _process(delta: float) -> void:
	position += transform.x * speed * delta
	var distatnce: float = position.distance_to(start_position)
	if distatnce > MAX_DISTANCE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()
