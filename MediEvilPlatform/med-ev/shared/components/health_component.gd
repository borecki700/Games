# actors/player/components/health_component.gd
class_name HealthComponent
extends Node

# ✅ Lokalny sygnał — każdy aktor obsługuje go sam
signal health_changed(current: int, maximum: int)
signal died()

var current_health: int
var max_health: int
var is_alive: bool = true


func initialize(p_max_health: int) -> void:
	max_health     = p_max_health
	current_health = p_max_health


func take_damage(amount: int) -> void:
	if not is_alive:
		return
	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)  # ← lokalny sygnał
	if current_health <= 0:
		_die()


func heal(amount: int) -> void:
	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)


func _die() -> void:
	is_alive = false
	died.emit()   # ← lokalny sygnał
