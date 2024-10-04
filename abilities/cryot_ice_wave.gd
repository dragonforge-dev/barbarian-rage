extends Area3D

class_name CryotIceWave

@export var collision_sound: AudioStream
@export var speed := 1.0

@onready var collision_shape = $CollisionShape3D
@onready var vfx = $IceFlowerEffect

var damage: int
var max_range: float


func set_damage(ice_wave_damage: float):
	damage = int(ice_wave_damage)


func set_range(ice_wave_range: float):
	max_range = ice_wave_range


func _ready() -> void:
	collision_shape.shape = CylinderShape3D.new()
	collision_shape.shape.height = 0.5
	collision_shape.shape.radius = 0.001
	vfx.set_flower_size(max_range)
	vfx.blossom()


func _physics_process(delta: float) -> void:
	if collision_shape.shape.radius < max_range: 
		collision_shape.shape.radius += max_range * delta * speed


func die():
	queue_free()


func _on_effect_timer_timeout() -> void:
	$MeltTimer.start()
	vfx.dissipate()


func _on_melt_timer_timeout() -> void:
	die()


func _on_body_entered(body: Node3D) -> void:
	Sounds.play_sound_effect(collision_sound)
	body.hit(damage, true)
