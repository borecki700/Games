# actors/enemies/skeleton/states/enemy_stun_state.gd
class_name EnemyStunState
extends BaseEnemyState

var _timer: float               = 0.0
var _knockback_velocity: Vector3 = Vector3.ZERO
var _recovery_timer: float      = 0.0
var _locked_rotation: float     = 0.0  # ← NOWE: zapamiętana rotacja

const KNOCKBACK_FORCE   := 6.0
const KNOCKBACK_DECAY   := 10.0
const RECOVERY_DURATION := 0.6


func enter(_d: Dictionary = {}) -> void:
	_timer          = data.stun_duration
	_recovery_timer = RECOVERY_DURATION

	# ✅ Zapamiętaj rotację w momencie trafienia
	_locked_rotation = enemy.rotation.y

	if player != null:
		var direction := (enemy.global_position - player.global_position)
		direction.y   = 0.0
		if direction != Vector3.ZERO:
			direction = direction.normalized()
		_knockback_velocity = direction * KNOCKBACK_FORCE
	else:
		_knockback_velocity = Vector3.ZERO


func physics_update(delta: float) -> void:
	navigation.apply_gravity(delta)

	# ✅ Przywracaj rotację każdą klatkę — blokuj wszelkie zmiany
	enemy.rotation.y = _locked_rotation

	# Faza 1 — aktywny knockback
	if _timer > 0.0:
		_timer -= delta
		enemy.velocity.x = _knockback_velocity.x
		enemy.velocity.z = _knockback_velocity.z
		_knockback_velocity = _knockback_velocity.move_toward(
			Vector3.ZERO, KNOCKBACK_DECAY * delta)
		return

	# Faza 2 — recovery (stoi nieruchomo)
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0
	_recovery_timer  -= delta

	if _recovery_timer <= 0.0:
		if is_player_in_range(data.detection_range):
			state_machine.transition_to("EnemyChaseState")
		else:
			state_machine.transition_to("EnemyIdleState")
