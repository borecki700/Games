# ui/hud/enemy_health_bar/enemy_health_bar.gd
class_name EnemyHealthBar
extends Control

@onready var _progress_bar: ProgressBar = $VBoxContainer/HealthProgressBar
@onready var _name_label: Label         = $VBoxContainer/EnemyNameLabel

# Referencja do śledzonego wroga
var _target_enemy: Node3D = null
var _camera: Camera3D     = null

# Offset nad głową wroga (w jednostkach świata)
const WORLD_OFFSET := Vector3(0.0, 2.5, 0.0)


func _ready() -> void:
	visible = false


func setup(camera: Camera3D) -> void:
	_camera = camera


func show_for_enemy(enemy: Node3D, enemy_name: String,
					current_hp: int, max_hp: int) -> void:
	_target_enemy           = enemy
	_name_label.text        = enemy_name
	_progress_bar.max_value = max_hp
	_progress_bar.value     = current_hp
	visible                 = true


func hide_bar() -> void:
	_target_enemy = null
	visible       = false


func update_health(current: int, maximum: int) -> void:
	var tween := create_tween()
	tween.tween_property(_progress_bar, "value", current, 0.15)\
		.set_ease(Tween.EASE_OUT)


func _process(_delta: float) -> void:
	if not visible or _target_enemy == null or _camera == null:
		return

	# ✅ Przelicz pozycję 3D wroga na 2D ekranu
	var world_pos   := _target_enemy.global_position + WORLD_OFFSET
	var screen_pos  := _camera.unproject_position(world_pos)

	# Wyśrodkuj pasek względem przeliczonej pozycji
	global_position  = screen_pos - size * 0.5

	# Ukryj gdy wróg za kamerą
	var is_in_front := _camera.is_position_in_frustum(world_pos)
	visible          = is_in_front
