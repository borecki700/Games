# actors/player/player.gd
class_name Player
extends CharacterBody3D

@export var stats: PlayerStats
@export var weapon_data: WeaponData

@onready var movement: MovementComponent         = $Components/MovementComponent
@onready var health: HealthComponent             = $Components/HealthComponent
@onready var animation: AnimationComponent       = $Components/AnimationComponent
@onready var combat: CombatComponent             = $Components/CombatComponent
@onready var lock_on: LockOnComponent            = $Components/LockOnComponent  # ← NOWE
@onready var state_machine: StateMachine         = $StateMachine
@onready var camera_controller: CameraController = $CameraRig
@onready var visuals: Node3D                     = $Visuals

@onready var _hitbox: HitboxComponent = $Visuals/AuxScene/Node/Skeleton3D/BoneAttachment3D/Sword/HitboxComponent


func _ready() -> void:
	add_to_group("player")
	assert(stats != null, "Player: brak PlayerStats!")
	assert(weapon_data != null, "Player: brak WeaponData!")

	movement.initialize(self, stats, camera_controller)
	health.initialize(stats.max_health)
	combat.initialize(self, _hitbox, weapon_data)

	# ✅ Lock-on inicjalizacja
	var cam := camera_controller.get_node("SpringArm3D/Camera3D") as Camera3D
	lock_on.initialize(self, cam)
	lock_on.target_acquired.connect(_on_lock_on_acquired)
	lock_on.target_released.connect(_on_lock_on_released)

	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)

	state_machine.start("IdleState")

	await get_tree().process_frame
	EventBus.player_health_changed.emit(health.current_health, health.max_health)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	# ✅ Toggle lock-on klawiszem
	if event.is_action_pressed("lock_on"):
		lock_on.toggle_lock_on()


func _on_lock_on_acquired(target: Node3D) -> void:
	movement.lock_on_target = target   # ruch wie o celu


func _on_lock_on_released() -> void:
	movement.lock_on_target = null


func _on_health_changed(current: int, maximum: int) -> void:
	EventBus.player_health_changed.emit(current, maximum)


func _on_died() -> void:
	EventBus.player_died.emit()
