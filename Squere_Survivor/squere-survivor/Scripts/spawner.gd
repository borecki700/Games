extends Node2D

const FAST_ENEMY = preload("uid://depdxr4sllql2")
const BOSS = preload("uid://clypwkgvbite")
const ENEMY = preload("uid://duyq5t5mkja04")
@onready var timer: Timer = $Timer


func _on_timer_timeout() -> void:
	var chance = randf()
	var enemy_scene
	
	if chance <= 0.1:
		enemy_scene = BOSS
	elif chance <= 0.4:
		enemy_scene = FAST_ENEMY
	else:
		enemy_scene = ENEMY
	var enemy = enemy_scene.instantiate()
	
	if Global.harder >= 10:
		# Zmniejszamy czas, ale nie pozwalamy mu spaść poniżej 0.2 sekundy
		timer.wait_time = max(0.2, timer.wait_time - 0.1) 
		# Resetujemy pomocniczy licznik w Global, 
		# żeby zacząć odliczać kolejne 10 punktów od zera
		Global.harder = 0 
		print("Poziom trudności wzrósł! Nowy czas: ", timer.wait_time)
		
	
	# 1. Pobierz aktualny rozmiar widoku (viewportu)
	var screen_size = get_viewport_rect().size
	
	# 2. Wybierz losową krawędź (0: Lewo, 1: Prawo, 2: Góra, 3: Dół)
	var edge = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match edge:
		0: # Lewo
			spawn_pos.x = -screen_size.x
			spawn_pos.y = randf_range(0, screen_size.y)
		1: # Prawo
			spawn_pos.x = screen_size.x 
			spawn_pos.y = randf_range(0, screen_size.y)
		2: # Góra
			spawn_pos.x = randf_range(0, screen_size.x)
			spawn_pos.y = -screen_size.y
		3: # Dół
			spawn_pos.x = randf_range(0, screen_size.x)
			spawn_pos.y = screen_size.y
	
	# 3. Ustaw pozycję i dodaj wroga
	enemy.global_position = spawn_pos
	add_child(enemy)
