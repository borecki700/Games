# actors/enemies/skeleton/states/enemy_death_state.gd
class_name EnemyDeathState
extends BaseEnemyState

const DESPAWN_TIME := 3.0
var _timer: float   = 0.0


func enter(_d: Dictionary = {}) -> void:
	_timer = DESPAWN_TIME

	# Wyłącz kolizję żeby gracz nie zaczepiał o trupa
	enemy.set_collision_layer_value(3, false)
	enemy.set_collision_mask_value(1, false)

	EventBus.enemy_died.emit(enemy)


func update(delta: float) -> void:
	enemy.queue_free()


func _set_alpha(alpha: float) -> void:
	# Ustawiamy przezroczystość na placeholderze
	var mesh := enemy.get_node_or_null("Visuals/MeshInstance3D") as MeshInstance3D
	if mesh == null:
		return
	var mat := mesh.get_active_material(0)
	if mat == null:
		return
	if mat is StandardMaterial3D:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = alpha
