# resources/weapon_data.gd
class_name WeaponData
extends Resource

@export_group("Info")
@export var weapon_name: String = "Sword"

@export_group("Combo")
# Każdy element tablicy = jeden cios w combo
# [damage, window_time, hitstop_duration]
@export var combo_damages: Array[int]       = [15, 20, 35]
@export var combo_windows: Array[float]     = [0.5, 0.5, 0.0]  # 0.0 = ostatni cios
@export var combo_durations: Array[float]   = [0.4, 0.4, 0.7]  # czas trwania ataku

@export_group("Feel")
@export var hitstop_duration: float = 0.08  # freeze przy trafieniu
@export var hit_pushback: float     = 2.5   # siła odpychania wroga

@export_group("Hitbox")
@export var hitbox_size: Vector3    = Vector3(0.4, 0.4, 0.8)
@export var hitbox_offset: Vector3  = Vector3(0.0, 0.0, -0.6)
