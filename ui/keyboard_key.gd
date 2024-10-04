@tool
extends Control


@export var key_enum: Key:
	set(value):
		if not is_node_ready():
			await ready
		key_enum = value
		key_name = OS.get_keycode_string(key_enum)
@export var key_name: String:
	set(value):
		if not is_node_ready():
			await ready
		key_name = value
		var filename = path + "keyboard_" + value
		var extension = ".png"
		var unpressed_filename = filename + "_outline" + extension
		var pressed_filename = filename + extension
		if ResourceLoader.exists(unpressed_filename):
			key_unpressed.texture = load(unpressed_filename)
		else:
			key_unpressed.texture = null
		if ResourceLoader.exists(pressed_filename):
			key_pressed.texture = load(pressed_filename)
		else:
			key_pressed.texture = null


@onready var key_unpressed = $Key_Unpressed
@onready var key_pressed = $Key_Pressed
@onready var path: String = "res://assets/ui/icons/input/keys_flat/"


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == key_enum:
			key_unpressed.hide()
			key_pressed.show()
	if event is InputEventKey and not event.pressed:
		if event.keycode == key_enum:
			key_pressed.hide()
			key_unpressed.show()
