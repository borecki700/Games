# resources/player_stats.gd
class_name PlayerStats
extends Resource

@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 9.0
@export var acceleration: float = 100.0
@export var deceleration: float = 100.0
@export var rotation_speed: float = 12.0

@export_group("Jump & Gravity")
@export var jump_force: float = 9.0
@export var gravity: float = 22.0
@export var fall_gravity_multiplier: float = 1.6  # cięższa grawitacja przy opadaniu
@export var coyote_time: float = 0.15             # gracz może skakać chwilę po krawędzi
@export var jump_buffer_time: float = 0.12        # skok "zapamiętany" przed lądowaniem

@export_group("Health")
@export var max_health: int = 100
