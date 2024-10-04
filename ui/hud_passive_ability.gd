@tool
extends Control

class_name HUDPassiveAbility

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

@onready var mask: Sprite2D = $Mask #self.get_node("Mask")
@onready var ability_icon: Sprite2D = $Mask/AbilityIcon #self.get_node("Mask/AbilityIcon")
@onready var level_label = $LevelLabel #self.get_node("LevelLabel")

var current_level: int = 0

func update_level(level: int):
	current_level = level
	if current_level > 0:
		level_label.text = str(current_level)
		self.show()
		level_label.show()
	else:
		self.hide()
		level_label.hide()
