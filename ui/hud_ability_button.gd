extends Button


# Stores the cost in peaks for each level
@onready var hud_overlay: CanvasLayer = $"../../.."
@onready var level_label = $Level
@onready var player: CharacterBody3D = hud_overlay.player

var current_level: int


func _ready() -> void:
	hud_overlay.check_levels.connect(update_level)


func update_level():
	current_level = player.ability_levels[name]
	if current_level > 0:
		level_label.text = str(current_level)
		self.show()
		level_label.show()
	else:
		self.hide()
		level_label.hide()
