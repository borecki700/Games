extends SpotLight3D

var picked_up = false
var flashlight_ui 
var flashlight_energy
var drain_rate = 0.02

func _ready() -> void:
	flashlight_ui = get_node("/root/" + get_tree().current_scene.name + "/UI/flashlight_stuff")
	flashlight_energy = get_node("/root/" + get_tree().current_scene.name + "/UI/flashlight_stuff/energy_slider")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("flashlight") and picked_up == true:
		visible = !visible
		flashlight_ui.visible = visible
		$toggle.play()
	if visible:
		flashlight_energy.value -= drain_rate * delta
	if flashlight_energy.value == 0 and visible == true:
		visible = false
		flashlight_ui.visible = false
