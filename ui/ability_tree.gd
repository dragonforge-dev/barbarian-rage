extends CanvasLayer

signal update_icon_levels
signal continue_button_pressed

@export var player: CharacterBody3D
@export var quant_labels: Array[Label]
@export var ability_screen_music: Song
@export var page_flip_sounds: Array[AudioStream]
@export var purchase_sound: AudioStream
@export var click_sound: AudioStream


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_quant_display()
	$MarginContainer/TextureRect/MarginContainer/VSplitContainer/HBoxContainer/VBoxContainer4/TimeDenial.grab_focus()


func update_quant_display():
	var peaks: int = player.peaks
	for label in quant_labels:
		label.text = str(posmod(peaks, 1000))
		peaks /= 1000
	update_icon_levels.emit()


func _on_visibility_changed() -> void:
	if visible:
		Sounds.play_music(ability_screen_music)
		Main.state = Main.STATE.GAMEPLAY_END
		update_quant_display()
		%ContinueButton.grab_focus()


func _on_continue_button_pressed() -> void:
	continue_button_pressed.emit()
	Sounds.play_sound_effect(click_sound)
