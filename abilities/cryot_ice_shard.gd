extends Area3D


@export var ice_shard_scene: PackedScene
@export var activation_sound: AudioStream

@onready var collision_shape = $CollisionShape3D

var targets: Array[Node]
var num_targets = 0


func create_shards(level: int) -> void:
	targets = get_tree().get_nodes_in_group("destructible")
	num_targets = level
	Sounds.play_sound_effect(activation_sound)
	
	var num_targets_found = targets.size()
	
	if targets.is_empty():
		return
	var current_target = 0
	
	for i in level:
		var ice_shard = ice_shard_scene.instantiate()
		ice_shard.set_damage(level)
		if targets[current_target] == null: # If the target is no longer valid
			print_rich("Target Removed: %s" % [targets[current_target]])
			targets.remove_at(current_target) # Remove it from our list
		ice_shard.set_target(targets[current_target])
		current_target += 1 # We want to iterate through the targets
		if current_target >= num_targets_found: # But if we have more ice shards than targets
			current_target = 0 # start over targeting at the beginning
		add_child(ice_shard)
		ice_shard.global_position = global_position


# Used by Volfrae
func get_number_of_targets():
	targets = get_tree().get_nodes_in_group("destructible")
	return targets.size()
