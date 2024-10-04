extends Area3D

class_name CryotIceBomb

@export var activation_sound: AudioStream
@export var explosion_sound: AudioStream
@export var collision_sounds: Array[AudioStream]
@export var speed := 2.0

@onready var collision_shape = $CollisionShape3D
@onready var delay_timer = $DelayTimer

var damage: int
var max_radius := 5.0
var is_exploding = false


func set_damage(ice_bomb_damage: float):
	damage = int(ice_bomb_damage)
	max_radius = ice_bomb_damage / 4


func set_delay(ice_bomb_delay: float):
	delay_timer.start(ice_bomb_delay)
	print_rich("[color=green]Delay Timer Started[/color]")


func _ready() -> void:
	collision_shape.shape = SphereShape3D.new()
	collision_shape.shape.radius = 0.1
	Sounds.play_sound_effect(activation_sound)


func _physics_process(delta: float) -> void:
	if is_exploding:
		if collision_shape.shape.radius < max_radius: 
			collision_shape.shape.radius += max_radius * delta * speed


func die():
	queue_free()


func _on_delay_timer_timeout() -> void:
	print_rich("[color=blue]Explosion Timer Started[/color]")
	$ExplosionTimer.start()
	is_exploding = true
	Sounds.play_sound_effect(explosion_sound)
	$IceOrb.explode()


func _on_explosion_timer_timeout() -> void:
	die()


func _on_body_entered(body: Node3D) -> void:
	Sounds.play_sound_effect(collision_sounds.pick_random())
	body.hit(damage, true)
