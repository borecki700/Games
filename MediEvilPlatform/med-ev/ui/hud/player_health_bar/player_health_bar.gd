# ui/hud/player_health_bar/player_health_bar.gd
class_name PlayerHealthBar
extends PanelContainer

@onready var _progress_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthProgressBar
@onready var _hp_label: Label           = $MarginContainer/VBoxContainer/HBoxContainer/HPLabel

var _max_health: int = 100


func _ready() -> void:
	# Podłącz do EventBus — UI nie zna gracza bezpośrednio
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_died.connect(_on_player_died)


func initialize(current: int, maximum: int) -> void:
	_max_health             = maximum
	_progress_bar.max_value = maximum
	_update_display(current, maximum)


func _on_health_changed(current: int, maximum: int) -> void:
	_max_health = maximum
	# Animowane zmniejszanie paska
	var tween := create_tween()
	tween.tween_property(_progress_bar, "value", current, 0.2)\
		.set_ease(Tween.EASE_OUT)
	_update_display(current, maximum)


func _on_player_died() -> void:
	_hp_label.text = "0 / %d" % _max_health
	var tween := create_tween()
	tween.tween_property(_progress_bar, "value", 0, 0.3)\
		.set_ease(Tween.EASE_OUT)


func _update_display(current: int, maximum: int) -> void:
	_hp_label.text          = "%d / %d" % [current, maximum]
	_progress_bar.max_value = maximum
	_progress_bar.value     = current
