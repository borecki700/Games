extends StaticBody3D

var flashlight_energy
var energy_add_amout = 0.5
var pick_up_sound
var flashlight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flashlight = get_node('/root/' + get_tree().current_scene.name + "/Player/Head/Flashlight")
	pick_up_sound = get_node('/root/' + get_tree().current_scene.name + "/Sounds/pick_up")
	flashlight_energy = get_node("/root/" + get_tree().current_scene.name + "/UI/flashlight_stuff/energy_slider")


func interact():
	if flashlight.picked_up == true:
		flashlight_energy.value += energy_add_amout
		pick_up_sound.play
		queue_free()
