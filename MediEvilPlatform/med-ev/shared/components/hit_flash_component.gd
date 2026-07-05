# shared/components/hit_flash_component.gd
class_name HitFlashComponent
extends Node

@export var flash_duration: float = 0.15

var _mesh: MeshInstance3D
var _material: ShaderMaterial
var _timer: float = 0.0
var _is_flashing: bool = false


func initialize(mesh: MeshInstance3D) -> void:
	_mesh = mesh
	_setup_shader()


func flash() -> void:
	if _material == null:
		return
	_timer       = flash_duration
	_is_flashing = true
	_material.set_shader_parameter("flash_amount", 1.0)


func _process(delta: float) -> void:
	if not _is_flashing:
		return
	_timer -= delta
	var t := clampf(_timer / flash_duration, 0.0, 1.0)
	_material.set_shader_parameter("flash_amount", t)
	if _timer <= 0.0:
		_is_flashing = false
		_material.set_shader_parameter("flash_amount", 0.0)


func _setup_shader() -> void:
	if _mesh == null:
		push_error("HitFlashComponent: brak MeshInstance3D!")
		return

	# ✅ Odczytaj oryginalny kolor PRZED nadpisaniem materialu
	var original_color := Color.RED  # fallback
	var existing_mat   := _mesh.get_active_material(0)
	if existing_mat is StandardMaterial3D:
		original_color = (existing_mat as StandardMaterial3D).albedo_color

	var shader  := load("res://assets/shaders/hit_flash.gdshader") as Shader
	_material    = ShaderMaterial.new()
	_material.shader = shader

	# ✅ Przekaż oryginalny kolor do shadera
	_material.set_shader_parameter("base_color", original_color)
	_material.set_shader_parameter("flash_color", Color.WHITE)
	_material.set_shader_parameter("flash_amount", 0.0)

	_mesh.material_override = _material
