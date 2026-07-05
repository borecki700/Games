extends CharacterBody3D

var speed = 2.5
var jumscareTime = 2
var player
var cought = false
var distance : float
var player_distance : float
@export var scene_name :String
@export var destinations : Array[Node3D]
var current_destination
var chasing = false
var able_to_pick = false
@export var walk_footsteps : Array[AudioStream]
@export var sprint_footsteps : Array[AudioStream]
var chase_timer = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	player = get_node("/root/" + get_tree().current_scene.name + "/Player")
	var random_dest = randi_range(0, destinations.size() - 1)
	current_destination = destinations[random_dest]

func pick_new_destination():
	if chasing == false and able_to_pick == false and distance <= 1 :
		able_to_pick = true
		speed = 0.0
		var wait_time = randf_range(3.0, 10.0)
		await  get_tree().create_timer(wait_time, false).timeout
		if distance <= 1 and chasing == false:
			var random_dest = randi_range(0, destinations.size() - 1)
			speed = 2.5
			current_destination = destinations[random_dest]
		able_to_pick = false


func _process(delta: float) -> void:
	if chasing == true and !$chase_music.playing:
		$chase_music.play()
	if chasing == false and $chase_music.playing:
		$chase_music.stop()

	if chasing == false and speed > 0:
		if !$footsteps.playing:
			var num = randi_range(0, walk_footsteps.size() - 1 )
			$footsteps.stream = walk_footsteps[num]
			$footsteps.play()
		distance = current_destination.global_transform.origin.distance_to(global_transform.origin)
		update_target_location(current_destination.global_transform.origin)
	if chasing == true and speed > 0 :
		if !$footsteps.playing:
			var num = randi_range(0, sprint_footsteps.size() - 1 )
			$footsteps.stream = sprint_footsteps[num]
			$footsteps.play()
		player_distance = player.global_transform.origin.distance_to(global_transform.origin)
		update_target_location(player.global_transform.origin)
	if chasing == true:
		if player_distance > 15:
			if chase_timer <= 5.0:
				chase_timer += 1 * delta
			else:
				chasing = false
				speed = 2.5
				chase_timer = 0.0
		else:
			chase_timer = 0.0



func _physics_process(delta: float) -> void:
	if visible:
		if not is_on_floor():
			velocity.y -= gravity * delta
	
	var current_location = global_transform.origin
	var next_location = $NavigationAgent3D.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * speed
	$NavigationAgent3D.set_velocity(new_velocity)
	var look_dir = atan2(-velocity.x, -velocity.z)
	rotation.y = lerp_angle(rotation.y, look_dir, delta * 6.0)
	if chasing == true:
		player_distance = global_transform.origin.distance_to(player.global_transform.origin)
		if player_distance <=2 and cought == false:
			player.visible = false
			$jumpscare.play()
			speed = 0
			cought = true
			$AnimationPlayer.play("jumpscare")
			$jumpscare_cam.current = true
			await get_tree().create_timer(2, false).timeout
			get_tree().change_scene_to_file("res://Scenes/death.tscn")

func update_target_location(target_location):
	$NavigationAgent3D.target_position = target_location


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if visible:
		velocity = velocity.move_toward(safe_velocity, 0.25)
		move_and_slide()
