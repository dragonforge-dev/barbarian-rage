extends Area3D

class_name IceShard

@export var collision_sound: AudioStream

var damage = 5
var rise_speed = 2.0
var rotation_speed = 5.0
var attack_speed = 50.0
var ready_to_move = false
var target: Node3D

var velocity = Vector3.ZERO
var acceleration = Vector3.ZERO


func _ready() -> void:
	set_as_top_level(true)
	self.body_entered.connect(_on_ice_shard_body_entered)
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start(1.38)


func _process(delta: float) -> void:
	if !is_instance_valid(target): # If our taregt is destroyed, we die.
		die()
		return
	if ready_to_move:
		position -= transform.basis.z * attack_speed * delta
		pass
	else:
		#Code for pointing towards the target
		var target_position = target.transform.origin
		var new_transform = self.transform.looking_at(target_position, Vector3.UP)
		self.transform  = self.transform.interpolate_with(new_transform, rotation_speed * delta)
		#code for rising up
		position += transform.basis.y * rise_speed * delta


func set_damage(level):
	damage = 5 * level


func set_target(node: Node3D):
	target = node


func _on_ice_shard_body_entered(body: Node3D) -> void:
	body.hit(damage, true)
	Sounds.play_sound_effect(collision_sound)
	die()


func die():
	queue_free()


func _on_timer_timeout() -> void:
	ready_to_move = true
