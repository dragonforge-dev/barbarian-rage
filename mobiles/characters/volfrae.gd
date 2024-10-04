extends CharacterBody3D

class_name Player

signal peaksChanged

@export var battle_hymns: Array[Song]
@export_file var action_script
@export var depression_timer: Timer
@export_group("Ability Base Values")
@export var base_speed := 5.0
@export var base_depression := 30.0
@export var base_damage := 5
@export var base_quant_multiplier := 1
@export var base_black_hole_range := 0.0
@export var base_ice_wave_damage := 5.0
@export var base_ice_wave_range := 0.5
@export var base_ice_bomb_damage := 15.0
@export var base_ice_bomb_delay := 15.0
@export_group("Physics")
@export var acceleration = 4.0
@export var mouse_sensitivity = 0.0075
@export var rotation_speed = 12.0

@onready var spring_arm = $SpringArm3D
@onready var model = $Rig
@onready var anim_tree = $AnimationTree
@onready var actions = Actions.new(anim_tree, self)
@onready var cryot_ice_shard = $"Rig/Skeleton3D/1H_Axe_Bone/CryotIceShard"
@onready var helm = $Rig/Skeleton3D/Barbarian_Hat_Bone/Barbarian_Hat
@onready var left_arm = $Rig/Skeleton3D/Barbarian_ArmLeft
@onready var right_arm = $Rig/Skeleton3D/Barbarian_ArmRight
@onready var armor = $Rig/Skeleton3D/Barbarian_Body
@onready var left_leg = $Rig/Skeleton3D/Barbarian_LegLeft
@onready var right_leg = $Rig/Skeleton3D/Barbarian_LegRight
@onready var cape = $Rig/Skeleton3D/Barbarian_Cape_Bone/Barbarian_Cape

var direction := Vector3.ZERO
var peaks: int = 0
var is_depressed = false
var game_paused = true
var is_ready = false

var depression_resistance := base_depression
var speed := base_speed
var damage := base_damage
var quant_multiplier := base_quant_multiplier
var black_hole_range := base_black_hole_range
var ice_wave_damage := base_ice_wave_damage
var ice_wave_range := base_ice_wave_range
var ice_bomb_damage := base_ice_bomb_damage
var ice_bomb_delay := base_ice_bomb_delay

var ability_levels = {
	"TimeDenial": 0, 
	"IceShard": 0,
	"RemorhazSpeed": 0,
	"Destruction": 0,
	"QuantCondenser": 0,
	"IceWave": 0,
	"BlackHole": 0,
	"IceBomb": 0,
	"IceSword": 0,
	"IceArmor": 0
	}
var earned_songs = {
	"TimeDenial": "res://assets/sound/music/denial/Smooth Sailing.tres", 
	"IceShard": "res://assets/sound/music/denial/OST 3 - Grand Palace.tres",
	"RemorhazSpeed": "res://assets/sound/music/anger/Battle-Furious.tres",
	"Destruction": "res://assets/sound/music/anger/Battle-Grief.tres",
	"QuantCondenser": "res://assets/sound/music/bargaining/OST 2 - A Place in My Heart.tres",
	"IceWave": "res://assets/sound/music/bargaining/OST 2 - Mystical Realm.tres",
	"BlackHole": "res://assets/sound/music/depression/Her Loss.tres",
	"IceBomb": "res://assets/sound/music/depression/Phobia.tres",
	"IceSword": "res://assets/sound/music/acceptance/OST 1 - Call of Deliverance.tres",
	"IceArmor": "res://assets/sound/music/acceptance/OST 4 - Meadow Path.tres"
	}


func _ready() -> void:
	Stats.connect_quant(self)
	self.ready.connect(_on_ready)


func _on_ready() -> void:
	is_ready = true

############
# MOVEMENT #
############


func _physics_process(delta: float) -> void:
	# Determine movement
	if game_paused or is_depressed or not is_ready:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	actions.process_input()
	update_velocity(Input.get_vector("move_left", "move_right", "move_forward", "move_backward"))

	#Move the Character
	velocity = lerp(velocity, direction * speed, acceleration * delta)
	var vl = velocity * model.transform.basis
	actions.do("move", Vector2(vl.x, -vl.z) / speed)
	move_and_slide()
	if velocity.length() > 1.0: rotate_character(spring_arm, delta) # If the player is moving, line the player up with the camera


# Directly updates the velocity. Is used by player input, and can be used
# to manually move the character for cutscene scripting or unit testing.
func update_velocity(input_dir: Vector2) -> void:
	#if is_player:
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, spring_arm.rotation.y)
	#else:
		#direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


# Rotates the character towards the rotation of the Node or Vector passed to it.
func rotate_character(target, delta: float = 0.0167) -> void:
	if target is SpringArm3D:
		model.rotation.y = lerp_angle(model.rotation.y, target.rotation.y, rotation_speed * delta)
		return
	elif target is Vector2:
		target = Vector3(target.x, global_position.y, target.y)
	elif target is Node:
		target = target.global_position
	
	model.look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)


#########
# INPUT #
#########


func _unhandled_input(event):
	if game_paused:
		return
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity


##########
# COMBAT #
##########


func _on_1h_axe_hit_body(body: Node3D) -> void:
	Sounds.play_sound_effect(body.hit(damage))


###########
# LOOTING #
###########


func pickup_item(item, amount, sound):
	if item == null:
		add_peaks(amount * quant_multiplier)
		Sounds.play_sound_effect(sound)
		print(name + " peaks: ", peaks)


func add_peaks(amount: int):
	peaks += amount
	peaksChanged.emit(amount)


###############
# START LEVEL #
###############


func start_depression() -> float:
	apply_time_denial()
	apply_remorhaz_speed()
	apply_destruction()
	apply_quant_condenser()
	apply_black_hole()
	apply_ice_wave()
	apply_ice_bomb()
	apply_ice_armor()
	apply_ice_sword()
	
	update_playlist()
	Sounds.play_music(battle_hymns.pick_random())
	
	if is_depressed:
		is_depressed = false
		actions.do("stand_up")
		
	if game_paused:
		game_paused = false
	
	depression_timer.start(depression_resistance)
	
	return depression_resistance


#############
# END LEVEL #
#############


func _on_depression_timer_timeout() -> void:
	actions.do("depression")
	is_depressed = true


####################
# ABILITY LEVELING #
####################


func update_playlist():
	for ability in ability_levels.keys():
		if ability_levels[ability] > 0:
			var song = load(earned_songs[ability])
			battle_hymns.append(song)


func apply_time_denial():
	depression_resistance = base_depression
	for level in ability_levels["TimeDenial"]:
		depression_resistance *= 1.125
	print_rich("Depression: %s" % [depression_resistance])


func apply_remorhaz_speed():
	speed = base_speed
	for level in ability_levels["RemorhazSpeed"]:
		speed = speed + (speed * 0.1)
	print_rich("Remorhaz Speed: %s" % [speed])
	anim_tree["parameters/SpeedModifier/scale"] = speed / 5
	print_rich("Animation Speed: %s" % [anim_tree["parameters/SpeedModifier/scale"]])

func apply_destruction():
	damage = base_damage
	for level in ability_levels["Destruction"]:
		damage *= 2
	print_rich("Destruction: %s" % [damage])


func apply_quant_condenser():
	quant_multiplier = base_quant_multiplier
	for level in ability_levels["QuantCondenser"]:
		quant_multiplier *= 10
	print_rich("QuantCondenser: %s" % [quant_multiplier])


func apply_black_hole():
	black_hole_range = base_black_hole_range
	for level in ability_levels["BlackHole"]:
		black_hole_range += 5
	print_rich("Black Hole Range: %s" % [black_hole_range])
	$BlackHole.set_range(black_hole_range)


func apply_ice_wave():
	ice_wave_damage = base_ice_wave_damage
	ice_wave_range = base_ice_wave_range
	for level in ability_levels["IceWave"]:
		ice_wave_damage *= 1.5
		ice_wave_range = ice_wave_range + (ice_wave_range * 0.5)
	print_rich("Ice Wave Damage: %s" % [ice_wave_damage])
	print_rich("Ice Wave Range: %s" % [ice_wave_range])


func apply_ice_bomb():
	ice_bomb_damage = base_ice_bomb_damage
	ice_bomb_delay = base_ice_bomb_delay
	for level in ability_levels["IceBomb"]:
		ice_bomb_damage = ice_bomb_damage + (ice_bomb_damage * 0.3)
		ice_bomb_delay = ice_bomb_delay * 0.75
	print_rich("Ice Bomb Damage: %s" % [ice_bomb_damage])
	print_rich("Ice Bomb Delay: %s" % [ice_bomb_delay])


func apply_ice_sword():
	if ability_levels["IceSword"] == 0:
		return
	$"Rig/Skeleton3D/1H_Axe_Offhand_Bone/1H_Axe_Offhand".hide()
	$"Rig/Skeleton3D/1H_Axe_Bone/1H_Axe".hide()
	$"Rig/Skeleton3D/2H_Axe_Bone/IceSword".show()


func apply_ice_armor():
	if ability_levels["IceArmor"] == 0:
		return
	var ice_material = preload("res://assets/materials/ice_001.material")
	var ice_overlay = preload("res://assets/materials/ice_101.material")
	helm.material_override = ice_material
	helm.material_overlay = ice_overlay
	left_arm.material_override = ice_material
	left_arm.material_overlay = ice_overlay
	right_arm.material_override = ice_material
	right_arm.material_overlay = ice_overlay
	armor.material_override = ice_material
	armor.material_overlay = ice_overlay
	left_leg.material_override = ice_material
	left_leg.material_overlay = ice_overlay
	right_leg.material_override = ice_material
	right_leg.material_overlay = ice_overlay
	cape.material_overlay = ice_overlay

func reset():
	peaks = 0
	for ability in ability_levels:
		ability = 0
