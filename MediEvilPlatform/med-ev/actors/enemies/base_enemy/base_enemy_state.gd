# actors/enemies/base_enemy/base_enemy_state.gd
class_name BaseEnemyState
extends BaseState

# Pola TYLKO dla wrogów — nie duplikujemy tego co jest w BaseState
var enemy: CharacterBody3D
var navigation: NavigationComponent
var combat: EnemyCombatComponent
var health: HealthComponent
var data: EnemyData

# player jest już w BaseState — NIE deklarujemy ponownie


func setup(owner_node: Node) -> void:
	# NIE wywołujemy super.setup() — wróg nie ma MovementComponent ani AnimationComponent
	state_machine = get_parent() as StateMachine
	enemy         = owner_node as CharacterBody3D

	var e      = owner_node as Skeleton
	navigation = e.navigation
	combat     = e.combat
	health     = e.health
	data       = e.data

	# player pochodzi z BaseState — przypisujemy przez grupę
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as Player


func distance_to_player() -> float:
	if player == null:
		return INF
	return enemy.global_position.distance_to(player.global_position)


func is_player_in_range(check_range: float) -> bool:
	return distance_to_player() <= check_range
