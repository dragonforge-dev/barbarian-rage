extends Node3D
@export var damage := 50

@onready var collision_shape = $sword_2handed_color/Blade/CollisionShape3D

func _on_blade_body_entered(body: Node3D) -> void:
	Sounds.play_sound_effect(body.hit(damage))


func set_collision_detection(collision_detection_on: bool):
	if collision_detection_on:
		print_rich("[color=red]Collision Detection ON")
		collision_shape.disabled = false
	else:
		print_rich("[color=blue]Collision Detection OF")
		collision_shape.disabled = true
