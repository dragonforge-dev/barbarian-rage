extends Node3D

class_name Destructible

signal death(item_name: String)
signal loot_dropped(dropped_item: Node)

@export var item_name: String
@export var health: int
@export var hit_sound: AudioStream
@export var death_sound: AudioStream
@export var loot: Array[PackedScene]

@onready var animation_player = $AnimationPlayer
@onready var spawn_effect_material = preload("res://effects/dissolve/dissolve.material")
@onready var frost_effect_material = preload("res://effects/ice_flower/frost.material")
@onready var dissolve_effect_material = preload("res://effects/dissolve/dissolve_3.material")
@onready var collision_shape_3d = $CollisionShape3D


var is_dying = false


func _ready() -> void:
	add_to_group("destructible")
	spawn()


func spawn():
	var material = spawn_effect_material.duplicate()
	for node in get_children():
		if node is MeshInstance3D:
			node.set_material_override(material)
	animation_player.play("Spawn")


func hit(damage: int, frost_effect: bool = false) -> AudioStream:
	if is_dying:
		return
	if frost_effect:
		for node in get_children():
			if node is MeshInstance3D:
				node.set_material_overlay(frost_effect_material)
	health -= damage
	if health <= 0:
		die(frost_effect)
	return hit_sound


func die(frost_effect: bool = false):
	is_dying = true
	collision_shape_3d.set_deferred("disabled",true)
	drop_loot()
	Sounds.play_sound_effect(death_sound)
	var material = dissolve_effect_material.duplicate()
	if not frost_effect:
		material.set_shader_parameter("EdgeColor", Color("#e68202"))
		material.set_shader_parameter("EdgeThickness", 0.1)
	for node in get_children():
		if node is MeshInstance3D:
			node.set_material_override(material)
	animation_player.play("Death")


func death_complete():
	death.emit(item_name)
	queue_free()


func drop_loot():
	if !loot.is_empty():
		for object in loot:
			var dropped_item = object.instantiate()
			get_parent_node_3d().add_child(dropped_item)
			dropped_item.global_position = global_position
			dropped_item.position.y += 0.05
			loot_dropped.emit(dropped_item)
