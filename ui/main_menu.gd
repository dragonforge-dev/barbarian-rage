extends CanvasLayer

signal return_to_game
signal new_game
signal save_game
signal load_game
signal open_ability_tree
signal level_select
signal start_new_level

@export var click_sound: AudioStream
@export var volume_confirm_sound: AudioStream

var level_select_available: int = 1
var game_loaded = false


func _ready() -> void:
	if OS.get_name() == "Web":
		%SaveButton.hide()
		%LoadButton.hide()
	resolve_level_select()
	get_parent().save_game_status.connect(_on_save_game_status_received)
	get_parent().load_game_status.connect(_on_load_game_status_received)
	%NewGameButton.grab_focus()


func _on_return_to_game_button_pressed() -> void:
	Sounds.play_sound_effect(click_sound)
	return_to_game.emit()


func _on_exit_button_pressed() -> void:
	Sounds.play_sound_effect(click_sound)
	await get_tree().create_timer(0.25).timeout # Just enough time to hear the click sound.
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_new_game_button_pressed() -> void:
	Sounds.play_sound_effect(click_sound)
	new_game.emit()


func _on_main_start_game() -> void:
	show()


func _on_save_button_pressed() -> void:
	Sounds.play_sound_effect(click_sound)
	save_game.emit()


func _on_save_game_status_received(status: bool):
	if status == true:
		$MessageLabel.text = "Game Saved"
		$AnimationPlayer.play("RESET")
		$AnimationPlayer.play("Fade Out Message Label")


func _on_load_button_pressed() -> void:
	Sounds.play_sound_effect(click_sound)
	load_game.emit()


func _on_load_game_status_received(status: bool, levels_available: int):
	if status == true:
		$MessageLabel.text = "Game Loaded"
		$AnimationPlayer.play("RESET")
		$AnimationPlayer.play("Fade Out Message Label")
		level_select_available = levels_available
		%ReturnToGameButton.hide()
		%SaveButton.show()
		%NewGameButton.show()
		%AbilityTreeButton.show()
		%EnterRageRoomButton.disabled = false
		for i in 5:
			%LevelButtons.get_node("SelectRoom" + str(i + 1)).disabled = false
		game_loaded = true
		resolve_level_select()
	else:
		$MessageLabel.text = "Load Game Failed: No Save File Found"
		$AnimationPlayer.play("RESET")
		$AnimationPlayer.play("Fade Out Message Label")


func get_volume(channel: Sounds.CHANNEL):
	match channel:
		Sounds.CHANNEL.MASTER:
			return %Master.value
		Sounds.CHANNEL.MUSIC:
			return %Music.value
		Sounds.CHANNEL.SFX:
			return %SFX.value
		Sounds.CHANNEL.DIALOGUE:
			return %Dialogue.value


func set_volume(volume: float, channel: Sounds.CHANNEL):
	match channel:
		Sounds.CHANNEL.MASTER:
			%Master.value = volume
		Sounds.CHANNEL.MUSIC:
			%Music.value = volume
		Sounds.CHANNEL.SFX:
			%SFX.value = volume
		Sounds.CHANNEL.DIALOGUE:
			%Dialogue.value = volume


func determine_if_new_level_is_available(level_completed: int):
	if level_completed == level_select_available:
		level_select_available += 1
		resolve_level_select()


func resolve_level_select():
	print("Levels Available: ", level_select_available)
	if Main.state == Main.STATE.START_MENU and game_loaded == false:
		%LevelSelect.hide()
	else:
		for i in 5:
			if level_select_available >= i + 1:
				%LevelButtons.get_node("SelectRoom" + str(i + 1)).visible = true
			else:
				%LevelButtons.get_node("SelectRoom" + str(i + 1)).visible = false
		%LevelSelect.show()


func _on_ability_tree_pressed() -> void:
	open_ability_tree.emit()
	hide()


func _on_level_select_toggled(toggled_on: bool, level: int) -> void:
	if toggled_on:
		Sounds.play_sound_effect(click_sound)
		level_select.emit(level)


func _on_play_rage_room_pressed() -> void:
	Sounds.play_sound_effect(click_sound)
	start_new_level.emit()


func _on_visibility_changed() -> void:
	if visible == true:
		match Main.state:
			Main.STATE.START_MENU:
				%NewGameButton.grab_focus()
				%ReturnToGameButton.hide()
				%SaveButton.hide()
				$MessageLabel.hide()
			Main.STATE.GAMEPLAY_END:
				resolve_level_select()
				%ReturnToGameButton.hide()
				%AbilityTreeButton.show()
				%SaveButton.show()
				$MessageLabel.hide()
				%NewGameButton.show()
				%EnterRageRoomButton.disabled = false
				for i in 5:
					%LevelButtons.get_node("SelectRoom" + str(i + 1)).disabled = false
				%EnterRageRoomButton.grab_focus()
			Main.STATE.GAMEPLAY_PAUSED:
				$MessageLabel.text = "Game Paused"
				%AbilityTreeButton.hide()
				$MessageLabel.show()
				%ReturnToGameButton.show()
				%ReturnToGameButton.grab_focus()
				%SaveButton.show()
				%NewGameButton.hide()
				%EnterRageRoomButton.disabled = true
				for i in 5:
					%LevelButtons.get_node("SelectRoom" + str(i + 1)).disabled = true
			Main.STATE.GAMEPLAY:
				%AbilityTreeButton.hide()
				$MessageLabel.hide()
