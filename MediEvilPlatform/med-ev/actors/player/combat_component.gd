# actors/player/components/combat_component.gd
class_name CombatComponent
extends Node

signal attack_started(combo_index: int)
signal attack_ended()
signal combo_finished()

var _player: Player
var _hitbox: HitboxComponent
var _animation: AnimationComponent
var weapon_data: WeaponData

var combo_index: int = 0
var is_attacking: bool = false
var combo_requested: bool = false

var _attack_timer: float = 0.0
var _combo_window: float = 0.0
var _hitstop_timer: float = 0.0
var _in_hitstop: bool = false

# ✅ NOWA FLAGA — okno combo jest teraz jawnie śledzone
var _combo_window_open: bool = false


func initialize(player: Player, hitbox: HitboxComponent, data: WeaponData) -> void:
	_player    = player
	_hitbox    = hitbox
	_animation = player.animation
	weapon_data = data


func _process(delta: float) -> void:
	if _in_hitstop:
		_tick_hitstop(delta)
		return
	if is_attacking:
		_tick_attack(delta)
	elif _combo_window > 0.0:
		_tick_combo_window(delta)


func try_attack() -> bool:
	if is_attacking:
		# ✅ combo_requested TYLKO gdy okno jest otwarte
		# Wcześniejsze kliknięcia są ignorowane
		if _combo_window_open:
			combo_requested = true
		return false

	if _combo_window > 0.0:
		# Gracz kliknął podczas okna combo (nie podczas ataku)
		combo_requested = true
		return false

	_start_attack(combo_index)
	return true


func reset_combo() -> void:
	combo_index        = 0
	combo_requested    = false
	_combo_window      = 0.0
	_combo_window_open = false
	is_attacking       = false
	_hitbox.disable()


func is_combo_requested() -> bool:
	return combo_requested


func _start_attack(index: int) -> void:
	combo_index        = index
	is_attacking       = true
	combo_requested    = false
	_combo_window_open = false        # ✅ okno zamknięte na start ataku

	_attack_timer = weapon_data.combo_durations[index]
	_combo_window = 0.0

	_hitbox.enable(weapon_data.combo_damages[index], _player)
	_animation.play_attack(index)
	attack_started.emit(combo_index)


func _tick_attack(delta: float) -> void:
	_attack_timer -= delta

	var duration := weapon_data.combo_durations[combo_index]

	# ✅ Okno combo otwiera się po 60% czasu ataku (nie 30%)
	# Animacja ma szansę dojść do punktu kulminacyjnego zanim przyjmiemy input
	if _attack_timer <= duration * 0.4 and not _combo_window_open:
		_hitbox.disable()
		_combo_window      = weapon_data.combo_windows[combo_index]
		_combo_window_open = true     # ✅ teraz akceptujemy input combo

	if _attack_timer <= 0.0:
		_finish_attack()


func _finish_attack() -> void:
	is_attacking       = false
	_combo_window_open = false
	_hitbox.disable()
	attack_ended.emit()

	if combo_index >= weapon_data.combo_damages.size() - 1:
		reset_combo()
		combo_finished.emit()


func _tick_combo_window(delta: float) -> void:
	_combo_window -= delta

	if combo_requested:
		combo_requested = false
		var next_index := (combo_index + 1) % weapon_data.combo_damages.size()
		_start_attack(next_index)
		return

	if _combo_window <= 0.0:
		reset_combo()
		combo_finished.emit()


func _tick_hitstop(delta: float) -> void:
	_hitstop_timer -= delta
	if _hitstop_timer <= 0.0:
		_in_hitstop       = false
		Engine.time_scale = 1.0
