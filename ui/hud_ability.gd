@tool
extends Control

class_name HUDAbility

@export var ability_icon_64_x_64_px: Texture:
	set(value):
		if not is_node_ready():
			await ready
		ability_icon_64_x_64_px = value
		ability_icon.texture = value
@export var is_round: bool = false:
	set(value):
		if not is_node_ready():
			await ready
		is_round = value
		if is_round:
			mask.set_clip_children_mode(Control.ClipChildrenMode.CLIP_CHILDREN_ONLY)
		else:
			mask.set_clip_children_mode(Control.ClipChildrenMode.CLIP_CHILDREN_DISABLED)


@onready var mask: TextureRect = $Mask
@onready var ability_icon: TextureRect = $Mask/AbilityIcon
@onready var level_label = $LevelLabel


var current_level: int = 0


func update_level(level: int):
	current_level = level
	if current_level > 0:
		level_label.text = str(current_level)
		get_parent().show()		
	else:
		get_parent().hide()
