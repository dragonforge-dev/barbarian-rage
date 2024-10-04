extends Node3D

@export var blossom_sound: AudioStream
@export var open_sound_loop: AudioStream
@export var dissipate_sound: AudioStream

@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer3D


func set_flower_size(radius: float) -> void:
	$FlowerMesh.scale = Vector3(radius, radius, radius)
	var modified_radius = radius / 3.79
	$CircleMesh.scale = Vector3(modified_radius, modified_radius, modified_radius)
	$Snow.process_material.set_emission_ring_radius(radius)
	$Snow2.process_material.set_emission_ring_radius(radius)

func blossom() -> void:
	animation_player.play("Blossom")
	if blossom_sound != null:
		audio_stream_player.set_stream(blossom_sound)
		audio_stream_player.play()


func play_open_sound_loop() -> void:
	if open_sound_loop != null:
		audio_stream_player.set_stream(open_sound_loop)
		audio_stream_player.play()


func dissipate() -> void:
	animation_player.play("Dissipate")
	if dissipate_sound != null:
		audio_stream_player.set_stream(dissipate_sound)
		audio_stream_player.play()
