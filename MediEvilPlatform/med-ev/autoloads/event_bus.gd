# autoloads/event_bus.gd
extends Node

# --- Player ---
signal player_health_changed(current: int, maximum: int)
signal player_died()
signal player_landed()
signal player_state_changed(new_state: String)

# --- Combat (przygotowane na Etap 2) ---
signal damage_dealt(amount: int, target: Node3D, source: Node3D)
signal enemy_died(enemy: Node3D)
signal hit_landed(position: Vector3)   # do efektów VFX/SFX

# --- World ---
signal checkpoint_reached(id: String)

# autoloads/event_bus.gd — dodaj na końcu
signal lock_on_acquired(target: Node3D)
signal lock_on_released()
signal lock_on_target_died()
