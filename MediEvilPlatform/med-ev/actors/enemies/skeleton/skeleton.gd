# skeleton.gd — zaktualizowana wersja
class_name Skeleton
extends CharacterBody3D

@export var data: EnemyData

var navigation: NavigationComponent
var combat: EnemyCombatComponent
var health: HealthComponent
var hit_flash: HitFlashComponent          # ← NOWE

@onready var _navigation_node: NavigationComponent   = $Components/NavigationComponent
@onready var _combat_node: EnemyCombatComponent      = $Components/EnemyCombatComponent
@onready var _health_node: HealthComponent           = $Components/HealthComponent
@onready var _hit_flash_node: HitFlashComponent      = $Components/HitFlashComponent  # ← NOWE
@onready var _agent: NavigationAgent3D               = $NavigationAgent3D
@onready var _state_machine: StateMachine            = $StateMachine
@onready var _hurtbox: HurtboxComponent              = $HurtboxComponent
@onready var _mesh: MeshInstance3D                   = $Visuals/MeshInstance3D  # ← ścieżka do mesha

var spawn_position: Vector3


func _ready() -> void:
	assert(data != null, "Skeleton: brak EnemyData!")
	spawn_position = global_position

	navigation = _navigation_node
	combat     = _combat_node
	health     = _health_node
	hit_flash  = _hit_flash_node

	navigation.initialize(self, _agent, data)
	combat.initialize(data)
	health.initialize(data.max_health)
	hit_flash.initialize(_mesh)

	_hurtbox.hit_received.connect(_on_hit_received)

	# ✅ Wróg NIE podłącza health.health_changed do EventBus.player_health_changed
	# Szkielet obsługuje swoją śmierć przez lokalny sygnał
	health.died.connect(_on_died)

	add_to_group("enemies")
	_state_machine.start("EnemyIdleState")


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_hit_received(damage: int, hit_position: Vector3, attacker: Node3D) -> void:
	health.take_damage(damage)
	hit_flash.flash()
	EventBus.damage_dealt.emit(damage, self, attacker)

	var hud := get_tree().get_first_node_in_group("hud") as HUD
	if hud != null:
		hud.show_enemy_health(self, data.enemy_name,
			health.current_health, health.max_health)

	if not health.is_alive:
		_state_machine.transition_to("EnemyDeathState")
	else:
		_state_machine.transition_to("EnemyStunState")


# ✅ Osobna metoda śmierci — nie miesza się z graczem
func _on_died() -> void:
	EventBus.enemy_died.emit(self)
