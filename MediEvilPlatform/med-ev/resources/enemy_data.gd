# resources/enemy_data.gd
class_name EnemyData
extends Resource

@export_group("Info")
@export var enemy_name: String = "Skeleton"

@export_group("Stats")
@export var max_health: int   = 50
@export var damage: int       = 10

@export_group("Movement")
@export var patrol_speed: float = 1.5
@export var chase_speed: float  = 3.5
@export var rotation_speed: float = 8.0

@export_group("Detection")
@export var detection_range: float = 8.0   # zasięg wykrycia gracza
@export var attack_range: float    = 1.5   # zasięg ataku
@export var lose_target_range: float = 12.0 # dystans utraty gracza

@export_group("Combat")
@export var attack_duration: float  = 0.8  # czas trwania animacji ataku
@export var attack_cooldown: float  = 1.5  # czas między atakami
@export var stun_duration: float    = 0.4  # czas ogłuszenia po trafieniu

@export_group("Patrol")
@export var patrol_wait_time: float = 2.0  # czas czekania w punkcie patrolu
@export var patrol_radius: float    = 5.0  # promień patrolu od pozycji startowej
