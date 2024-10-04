extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("Animation")

func explode() -> void:
	$AnimationPlayer.stop()
	$ExplosionAnimationPlayer.play("Explosion")
