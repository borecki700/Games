extends Node3D

@export var flash_lights_at_rand : bool
@export var min_time : float
@export var max_time : float
@export var min_flash_time : float
@export var max_flash_time : float
@export var loop_flashing : bool
var loop = true

func _process(delta: float) -> void:
	if loop == true and flash_lights_at_rand == true:
		loop = false
		var rand = randf_range(min_time, max_time)
		await get_tree().create_timer(rand, false).timeout
		var anim = $AnimationPlayer.get_animation("flashing_light")
		if loop_flashing == true:
			anim.loop_mode = Animation.LOOP_LINEAR
			$AnimationPlayer.play("flashing_light")
			$flicker_sound.play()
			var rand2 = randf_range(min_flash_time, max_flash_time)
			await get_tree().create_timer(rand2, false).timeout
			anim.loop_mode = Animation.LOOP_NONE
			$AnimationPlayer.stop()
			$flicker_sound.stop()
			loop = true
		else:
			anim.loop_mode = Animation.LOOP_NONE
			$AnimationPlayer.play("flashing_light")
			loop = true
