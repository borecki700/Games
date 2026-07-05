extends CharacterBody2D
@export var spear_scene: PackedScene
@export var speed := 150
@export var jump_force := -250
@export var gravity := 600
@export var max_jumps := 1
@export var max_health := 3
var current_health := max_health

var jumps_left := 1
var can_throw := true
@export var throw_cooldown := 0.5  # w sekundach
@onready var ladder_detector = $LadderDetector
@onready var sprite := $AnimatedSprite2D
@export var climb_speed := 100.0
var on_ladder = false
var is_climbing = false

func _ready():
	sprite.play("idle")

func _physics_process(delta):
	velocity.x = 0
	# --- Wspinanie po drabinie ---
	if on_ladder and (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
		is_climbing = true
	if is_climbing:
		velocity.y = 0  # Brak grawitacji
		if Input.is_action_pressed("ui_up"):
			velocity.y = -climb_speed
		elif Input.is_action_pressed("ui_down"):
			velocity.y = climb_speed
		else:
			velocity.y = 0
		# Schodzenie z platformy w dół przez drabinę
		if Input.is_action_just_pressed("ui_down") and is_on_floor():
			disable_floor_temporarily()
		# Wyjście z drabiny
		if not on_ladder or is_on_floor():
			is_climbing = false
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			jumps_left = max_jumps
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = jump_force
				jumps_left -= 1
		if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
			velocity.y = jump_force
			jumps_left -= 1
	# --- Ruch poziomy + animacje ---
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		sprite.flip_h = false
		sprite.play("run")
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= speed
		sprite.flip_h = true
		sprite.play("run")
	else:
		sprite.play("idle")
	# --- Rzucanie włócznią ---
	if Input.is_action_just_pressed("throw"):
		throw_weapon()
	move_and_slide()

func take_damage(amount := 1):
	current_health -= amount
	if current_health < 0:
		current_health = 0
	Ui.update_health_bar(current_health)
	if current_health <= 0:
		die()

func die():
	$AnimatedSprite2D.play("death")
	set_process(false)
	set_physics_process(false)
	get_tree().change_scene_to_file("res://GameOver/game_over.tscn")


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		take_damage(1)


func _on_ladder_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		on_ladder = true


func _on_ladder_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		on_ladder = false
		is_climbing = false

func disable_floor_temporarily():
	set_collision_mask_value(1, false)  # Wyłącz kolizję z platformami
	await get_tree().create_timer(0.3).timeout
	set_collision_mask_value(1, true)

func throw_weapon():
	if not WeaponMenager.can_attack:
		return
	var dir = Vector2.RIGHT if not sprite.flip_h else Vector2.LEFT
	var spawn_position = $Marker2D.global_position
	WeaponMenager.use_weapon(spawn_position, dir, spear_scene)
