# actors/player/weapons/hitbox_component.gd
class_name HitboxComponent
extends Area3D

signal hit_landed(hurtbox: HurtboxComponent, hit_position: Vector3)

var damage: int = 0
var attacker: Node3D


func _ready() -> void:
	# Hitbox domyślnie WYŁĄCZONY — włączamy tylko podczas ataku
	monitoring = false
	monitorable = false
	# Podłączamy sygnał wykrycia obszaru
	area_entered.connect(_on_area_entered)


func enable(p_damage: int, p_attacker: Node3D) -> void:
	damage    = p_damage
	attacker  = p_attacker
	monitoring  = true
	monitorable = true


func disable() -> void:
	monitoring  = false
	monitorable = false


func _on_area_entered(area: Area3D) -> void:
	if area is HurtboxComponent:
		var hit_pos := area.global_position
		area.receive_hit(damage, hit_pos, attacker)
		hit_landed.emit(area, hit_pos)
		# Emitujemy globalny sygnał dla VFX/SFX
		EventBus.hit_landed.emit(hit_pos)
