extends Button

class_name Ability

# Stores the cost in peaks for each level
@export var cost_in_peaks: Array[int]
@export_multiline var short_description: String
@export_multiline var long_description: String

@onready var ability_tree: CanvasLayer = $"../../../../../../.."
@onready var level_label = $MarginContainer/Level
@onready var short_description_container: MarginContainer = %ShortDescriptionMarginContainer
@onready var short_description_label: Label = %ShortDescriptionLabel
@onready var description_container: MarginContainer = %DescriptionMarginContainer
@onready var description_label: Label = %DescriptionLabel
@onready var ability_name_label: Label = %AbilityNameLabel
@onready var ability_cost_label: Label = %AbilityCostLabel
@onready var ability_seperator: HSeparator = %AbilityHSeparator

# Tooltip Description
var player: CharacterBody3D
var current_level: int


func _ready() -> void:
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	self.pressed.connect(_on_button_pressed)
	ability_tree.update_icon_levels.connect(update_level)

	player = ability_tree.player
	update_level()


func update_level():
	current_level = player.ability_levels[name]
	if current_level > 0:
		level_label.text = str(current_level)
		level_label.show()


func update_labels() -> void:
	ability_name_label.text = text
	ability_cost_label.text = get_cost()
	short_description_label.text = short_description
	description_label.text = long_description


func _on_mouse_entered() -> void:
	update_labels()
	short_description_container.show()
	description_container.show()
	Sounds.play_sound_effect(ability_tree.page_flip_sounds.pick_random())
	%ContinueButton.hide()


func _on_mouse_exited() -> void:
	short_description_label.text = "Press ESC to pick a new level."
	description_container.hide()
	%ContinueButton.show()


#on click subtracts amount and sets value.	
func _on_button_pressed():
	if current_level < cost_in_peaks.size():
		if cost_in_peaks[current_level] <= player.peaks:
			player.peaks -= cost_in_peaks[current_level]
			player.ability_levels[name] += 1
			ability_tree.update_quant_display()
			update_level()
			update_labels()
			Sounds.play_sound_effect(ability_tree.purchase_sound)


func get_cost() -> String:
	if current_level >= cost_in_peaks.size():
		return "Max Level"
	var cost = cost_in_peaks[current_level]
	if cost < 1000:
		return str(cost) + " Peaks"
	cost /= 1000
	if cost < 1000:
		return str(cost) + " Nahn"
	cost /= 1000
	if cost < 1000:
		return str(cost) + " Cron"
	cost /= 1000
	if cost < 1000:
		return str(cost) + " Mils"
	cost /= 1000
	return str(cost) + " Quant"
