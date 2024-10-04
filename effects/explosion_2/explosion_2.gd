extends Node3D

@onready var sphere := $MeshInstance3D
var sphere_time := 0.0

func _process(_delta: float) -> void:
	if Input.is_action_pressed("attack"):
		sphere_time = lerp(sphere_time, 3.5, 0.025)
		sphere.mesh.material.set_shader_parameter("Time", sphere_time)
	elif Input.is_action_pressed("stop"):
		sphere_time = lerp(sphere_time, 0.0, 0.025)
		sphere.mesh.material.set_shader_parameter("Time", sphere_time)
