extends Node3D

signal level_complete

@export var x_width: float = 1.0
@export var z_length: float = 1.0
@export var small_barrels: int
@export var small_boxes: int
@export var large_barrels: int
@export var large_boxes: int
@export var barrel_stacks: int
@export var small_barrel: PackedScene
@export var small_box: PackedScene
@export var large_barrel: PackedScene
@export var large_box: PackedScene
@export var barrel_stack: PackedScene

var rng = RandomNumberGenerator.new()
var level_started = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_rich("x/z(%s,%s)" % [x_width, z_length])
	propogate(small_barrels, small_barrel)
	propogate(small_boxes, small_box)
	propogate(large_barrels, large_barrel)
	propogate(large_boxes, large_box)
	propogate(barrel_stacks, barrel_stack)
	level_started = true


func propogate(number: int, scene: PackedScene):
	for i in number:
		spawn(scene)


func spawn(destructible: PackedScene) -> void:
	var destructible_copy = destructible.instantiate()
	destructible_copy.position.x = rng.randf_range(-x_width, x_width)
	destructible_copy.position.z = rng.randf_range(-z_length, z_length)
	add_child(destructible_copy)
	destructible_copy.death.connect(_on_item_destroyed)
	Stats.connect_death(destructible_copy)
	destructible_copy.loot_dropped.connect(_on_loot_dropped)


func _on_loot_dropped(loot):
	loot.death.connect(_on_item_destroyed)


func _on_item_destroyed(_arg1 = null):
	var destructibles = get_tree().get_node_count_in_group("destructible")
	var pickups = get_tree().get_node_count_in_group("pickup")
	if destructibles + pickups <= 1:
		level_complete.emit()
		level_started = false
