extends CharacterBody3D

var original_speed
var speed = 5.0
var sprint_speed = 7.0
const JUMP_VELOCITY = 4.5
var sprint_drain_amount = 0.3
var sprint_slider
var sprint_refresh_amount = 0.4
#DLA GRY NORMALNEJ movable = false dla testu movable = true
var movable = false
@export var walk_footsteps : Array[AudioStream]
@export var sprint_footsteps : Array[AudioStream]

func _ready() -> void:
	original_speed = speed
	sprint_slider = get_node("/root/" + get_tree().current_scene.name + "/UI/sprint_slider")

func _process(delta: float) -> void:
	if speed == sprint_speed:
		sprint_slider.value = sprint_slider.value - sprint_drain_amount * delta
		if sprint_slider.value <= sprint_slider.min_value:
			speed = original_speed
	if speed != sprint_speed:
		if sprint_slider.value < sprint_slider.max_value:
			sprint_slider.value = sprint_slider.value + sprint_refresh_amount * delta
		if sprint_slider.value == sprint_slider.max_value:
			sprint_slider.visible = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if movable == true:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if !$footstep_sound.playing:
				if speed != sprint_speed:
					var num = randi_range(0, walk_footsteps.size() - 1 )
					$footstep_sound.stream = walk_footsteps[num]
				else:
					var num = randi_range(0, sprint_footsteps.size() - 1 )
					$footstep_sound.stream = sprint_footsteps[num]
				$footstep_sound.play()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if Input.is_action_pressed("sprint"):
				sprint_slider.visible = true
				speed = sprint_speed
			if Input.is_action_just_released("sprint"):
				speed = original_speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		move_and_slide()
