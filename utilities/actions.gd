extends Object

class_name Actions

enum ATTACK {
	NONE,
	SLICE,
	DUAL,
	TWO_HAND_SLICE,
	SPIN
}


var animation_tree: AnimationTree
var character: Player
var current_attack: ATTACK = ATTACK.NONE
var next_attack: ATTACK = ATTACK.NONE
var ice_wave_scene = load("res://abilities/cryot_ice_wave.tscn")
var ice_bomb_scene = load("res://abilities/cryot_ice_bomb.tscn")


func _init(anim_tree: AnimationTree, player: Player):
	animation_tree = anim_tree
	animation_tree.animation_finished.connect(_on_animation_finished)
	character = player


func process_input():
	# Attack
	if Input.is_action_just_pressed("attack"):
		do("attack")
	if Input.is_action_just_pressed("heavy_attack"):
		do("heavy_attack")
	if Input.is_action_just_pressed("ice_shards"):
		do("ice_shards")
	if Input.is_action_just_pressed("ice_wave"):
		do("ice_wave")
	if Input.is_action_just_pressed("ice_bomb"):
		do("ice_bomb")


func do(action: Variant, arg1: Variant = null) -> void:
	match action:
		#Movement
		"move":
			animation_tree.set("parameters/IWR/blend_position", arg1)
		#Attack Actions
		"attack":
			if character.ability_levels["IceSword"] == 0:
				resolve_attack(ATTACK.SLICE, "Slice")
			else:
				resolve_attack(ATTACK.TWO_HAND_SLICE, "2HSlice")
		"heavy_attack":
			if character.ability_levels["IceSword"] == 0:
				resolve_attack(ATTACK.DUAL, "Dual")
			else:
				resolve_attack(ATTACK.SPIN, "Spin")
		#Depression
		"depression":
			animation_tree["parameters/Depression/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		"stand_up":
			animation_tree.get("parameters/DepressionState/playback").travel("Lie_StandUp")
		#Cryot Abilities
		"ice_shards":
			var num_targets = character.cryot_ice_shard.get_number_of_targets()
			print_rich("Number of Targets: %s" % num_targets)
			if character.ability_levels["IceShard"] >  0 and num_targets > 0:
				animation_tree["parameters/IceShard/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
				character.cryot_ice_shard.create_shards(character.ability_levels["IceShard"])
		"ice_wave":
			if character.ability_levels["IceWave"] >  0:
				var ice_wave = ice_wave_scene.instantiate()
				ice_wave.set_damage(character.ice_wave_damage)
				ice_wave.set_range(character.ice_wave_range)
				character.get_tree().root.add_child(ice_wave)
				ice_wave.global_position = character.global_position
				animation_tree["parameters/IceShard/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		"ice_bomb":
			if character.ability_levels["IceBomb"] >  0:
				var ice_bomb = ice_bomb_scene.instantiate()
				character.get_tree().root.add_child(ice_bomb)
				ice_bomb.global_position = character.global_position
				ice_bomb.set_damage(character.ice_bomb_damage)
				ice_bomb.set_delay(character.ice_bomb_delay)
				animation_tree["parameters/IceShard/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func _on_animation_finished(animation_name: String):
	if animation_name.contains("Melee_Attack"):
		current_attack = next_attack
		match current_attack:
			ATTACK.SLICE:
				execute_attack("Slice")
			ATTACK.DUAL:
				execute_attack("Dual")
			ATTACK.TWO_HAND_SLICE:
				execute_attack("2HSlice")
			ATTACK.SPIN:
				execute_attack("Spin")


func execute_attack(attack_name: String):
	animation_tree["parameters/AttackType/transition_request"] = attack_name
	animation_tree["parameters/Attack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	next_attack = ATTACK.NONE


func resolve_attack(attack: ATTACK, name: String):
	if current_attack == ATTACK.NONE:
		current_attack = attack
		execute_attack(name)
	else:
		next_attack = attack
