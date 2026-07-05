# actors/enemies/skeleton/states/enemy_attack_state.gd
class_name EnemyAttackState
extends BaseEnemyState


func enter(_d: Dictionary = {}) -> void:
	# ✅ Zatrzymaj nawigację — agent przestaje obliczać ścieżkę i rotację
	navigation.stop()

	if not combat.can_attack():
		state_machine.transition_to("EnemyChaseState")
		return

	combat.start_attack()
	combat.attack_finished.connect(_on_attack_finished)

	# Obróć w stronę gracza — jednorazowo, po stop()
	if player != null:
		var dir := (player.global_position - enemy.global_position)
		dir.y    = 0.0
		if dir != Vector3.ZERO:
			enemy.rotation.y = atan2(dir.x, dir.z)

	_try_deal_damage()


func exit() -> void:
	if combat.attack_finished.is_connected(_on_attack_finished):
		combat.attack_finished.disconnect(_on_attack_finished)


func physics_update(delta: float) -> void:
	# Tylko grawitacja — nawigacja zatrzymana
	navigation.apply_gravity(delta)
	# ✅ Wyzeruj poziome velocity każdą klatkę — agent może je resetować
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0


func _try_deal_damage() -> void:
	if player == null:
		return
	if is_player_in_range(data.attack_range):
		player.health.take_damage(combat.get_damage())
		EventBus.damage_dealt.emit(combat.get_damage(), player, enemy)


func _on_attack_finished() -> void:
	if is_player_in_range(data.detection_range):
		state_machine.transition_to("EnemyChaseState")
	else:
		state_machine.transition_to("EnemyIdleState")
