# ui/hud/hud.gd
class_name HUD
extends CanvasLayer

@onready var _player_hp: PlayerHealthBar = $PlayerHealthBar
@onready var _enemy_hp: EnemyHealthBar   = $EnemyHealthBar

# Referencja do kamery — potrzebna dla przeliczenia 3D→2D
var _camera: Camera3D


func _ready() -> void:
	add_to_group("hud")    # ← DODAJ
	# Znajdź kamerę w scenie
	await get_tree().process_frame
	_camera = get_viewport().get_camera_3d()
	_enemy_hp.setup(_camera)

	# Podłącz sygnały EventBus
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.damage_dealt.connect(_on_damage_dealt)


func initialize_player(current: int, maximum: int) -> void:
	_player_hp.initialize(current, maximum)


func show_enemy_health(enemy: Node3D, enemy_name: String,
					   current_hp: int, max_hp: int) -> void:
	_enemy_hp.show_for_enemy(enemy, enemy_name, current_hp, max_hp)


func _on_enemy_died(enemy: Node3D) -> void:
	if _enemy_hp._target_enemy == enemy:
		_enemy_hp.hide_bar()


func _on_damage_dealt(amount: int, target: Node3D, _source: Node3D) -> void:
	# Aktualizuj pasek HP wroga gdy dostaje obrażenia
	if target is Skeleton:
		var skeleton := target as Skeleton
		_enemy_hp.update_health(skeleton.health.current_health,
								skeleton.health.max_health)
