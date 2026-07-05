extends Node

enum WeaponType { SPEAR, TORCH }

var current_weapon = WeaponType.SPEAR
var can_attack = true
var cooldown := 0.5

signal weapon_used
signal weapon_cooldown_updated(value: float)

var cooldown_timer: Timer

# 🔥 Torch-specific:
var active_torches := 0
const MAX_TORCHES := 2

func _ready():
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))
	add_child(cooldown_timer)

func use_weapon(position: Vector2, direction: Vector2, scene: PackedScene):
	if not can_attack or scene == null:
		return

	# 🧯 Blokada, jeśli próbujemy rzucić za dużo pochodni
	if current_weapon == WeaponType.TORCH and active_torches >= MAX_TORCHES:
		return

	can_attack = false
	emit_signal("weapon_used")
	emit_signal("weapon_cooldown_updated", cooldown)
	cooldown_timer.start()

	var projectile = scene.instantiate()
	projectile.global_position = position
	projectile.direction = direction
	get_tree().current_scene.add_child(projectile)

	# 🔥 Rejestruj pochodnię, jeśli to torch
	if current_weapon == WeaponType.TORCH:
		active_torches += 1
		projectile.connect("tree_exited", Callable(self, "_on_torch_removed"))

func _on_torch_removed():
	active_torches = max(0, active_torches - 1)

func _on_cooldown_timeout():
	can_attack = true
