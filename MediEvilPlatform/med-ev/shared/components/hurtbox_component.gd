# shared/components/hurtbox_component.gd
class_name HurtboxComponent
extends Area3D

# Emitowany gdy coś trafia w tego hurtboxa
signal hit_received(damage: int, hit_position: Vector3, attacker: Node3D)

# Właściciel hurtboxa (gracz, wróg) — ustawiany automatycznie
var owner_node: Node3D


func _ready() -> void:
	owner_node = get_parent()
	# Reagujemy tylko gdy hitbox WCHODZI w nasz obszar
	# (nie chcemy wielokrotnych trafień w jednej klatce)
	monitoring = true
	monitorable = true


func receive_hit(damage: int, hit_position: Vector3, attacker: Node3D) -> void:
	hit_received.emit(damage, hit_position, attacker)
