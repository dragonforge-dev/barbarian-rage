extends Node3D

signal start_game
signal enter_level
signal save_game_status(success: bool)
signal load_game_status(success: bool, levels_available: int)

@export var player: CharacterBody3D
@export var beginning_music: Song
@export var success_music: Song
@export var failure_music: Array[Song]
@export var save_path := "user://barbarianrage.save"
@export var settings_path := "user://barbarianrage.settings"
@export var levels: Array[PackedScene]

var rage_room: Node3D
var level_selected = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.state = Main.STATE.START_MENU
	Sounds.connect_players()
	start_game.emit()
	load_settings()
	Sounds.play_music(beginning_music)
	$MainMenu.open_ability_tree.connect(_show_ability_tree)
	$MainMenu.level_select.connect(_select_level)
	$MainMenu.start_new_level.connect(_start_new_level)
	$AbilityTree.continue_button_pressed.connect(_on_continue_button_pressed)


func _notification(what) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: #Called when the application quits.
			save_settings()


func _on_depression_timer_timeout() -> void:
	Stats.add_game_running_time($DepressionTimer.get_wait_time())
	$DepressionTimer.stop()
	$HUDOverlay.show_time_up_label()
	var stream: Song = failure_music.pick_random()
	Sounds.play_music(stream)
	$DelayTimer.start(stream.song.get_length())
	Stats.depressed_again()


func _on_delay_timer_timeout() -> void:
	_end_level()
	_show_ability_tree()
	$MainMenu.hide()


func start_level()  -> void:
	Main.state = Main.STATE.GAMEPLAY
	enter_level.emit()
	$MainMenu.hide()
	$AbilityTree.hide()
	rage_room.show()
	rage_room.level_complete.connect(_on_rage_room_level_complete)
	player.position = Vector3(0,0,0)
	player.show()
	$HUDOverlay.start_level(player.start_depression())
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	unpause_game()


func _unhandled_input(_event):
	if Input.is_action_just_pressed("main_menu"):
		match Main.state:
			Main.STATE.START_MENU:
				return
			Main.STATE.GAMEPLAY_END:
				if $MainMenu.visible:
					$MainMenu.hide()
				else:
					$MainMenu.show()
			Main.STATE.GAMEPLAY_PAUSED:
				unpause_game()
			Main.STATE.GAMEPLAY:
				pause_game()


func pause_game() -> void:
	Main.state = Main.STATE.GAMEPLAY_PAUSED
	$MainMenu.show()
	$DepressionTimer.paused = true
	$DelayTimer.paused = true
	player.game_paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$HUDOverlay.pause_game()
	Sounds.pause_music()


func unpause_game() -> void:
	Main.state = Main.STATE.GAMEPLAY
	$MainMenu.hide()
	Sounds.unpause_music()
	$DepressionTimer.paused = false
	$DelayTimer.paused = false
	player.game_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$HUDOverlay.unpause_game()


func _on_main_menu_return_to_game() -> void:
	unpause_game()


func _on_main_menu_new_game() -> void:
	player.reset()
	create_rage_room(levels[0])
	start_level()


func save_file(save_information: Dictionary, path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_var(save_information)
	return true


func load_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	return file.get_var()


func _on_main_menu_save_game() -> void:
	var save_information = {
		"peaks" : player.peaks,
		"ability_levels" : player.ability_levels,
		"stats" : Stats.stats,
		"level_available" : $MainMenu.level_select_available
	}
	save_game_status.emit(save_file(save_information, save_path))


func _on_main_menu_load_game() -> void:
	var save_information = load_file(save_path)
	if save_information == null:
		load_game_status.emit(false, 0)
		return

	player.peaks = save_information["peaks"]
	player.ability_levels = save_information["ability_levels"]
	$AbilityTree.update_quant_display()
	Stats.stats = save_information["stats"]
	print_rich(Stats.stats)
	var level_available = save_information["level_available"]

	load_game_status.emit(true, level_available)
	_end_level()


func save_settings() -> void:
	var save_information = {
		"master_volume" : $MainMenu.get_volume(Sounds.CHANNEL.MASTER),
		"music_volume" : $MainMenu.get_volume(Sounds.CHANNEL.MUSIC),
		"sfx_volume" : $MainMenu.get_volume(Sounds.CHANNEL.SFX),
		"dialogue_volume" : $MainMenu.get_volume(Sounds.CHANNEL.DIALOGUE)
	}
	save_file(save_information, settings_path)


func load_settings() -> void:
	var save_information = load_file(settings_path)
	if save_information == null:
		return

	$MainMenu.set_volume(save_information["master_volume"], Sounds.CHANNEL.MASTER)
	$MainMenu.set_volume(save_information["music_volume"], Sounds.CHANNEL.MUSIC)
	$MainMenu.set_volume(save_information["sfx_volume"], Sounds.CHANNEL.SFX)
	$MainMenu.set_volume(save_information["dialogue_volume"], Sounds.CHANNEL.DIALOGUE)


func _on_rage_room_level_complete() -> void:
	Stats.add_game_running_time($DepressionTimer.get_wait_time() - $DepressionTimer.get_time_left())
	$DepressionTimer.stop()
	Sounds.play_music(success_music)
	$DelayTimer.start(success_music.song.get_length())
	$HUDOverlay.show_level_complete_label()
	Stats.triumph()
	$MainMenu.determine_if_new_level_is_available(level_selected + 1)


func create_rage_room(scene: PackedScene):
	rage_room = scene.instantiate()
	add_child(rage_room)
	player.reparent(rage_room)
	player.position.y = 0.01


func _show_ability_tree():
	$AbilityTree.show()


func _select_level(level):
	level_selected = level


func _start_new_level():
	create_rage_room(levels[level_selected])
	start_level()


func _on_continue_button_pressed():
	$MainMenu.show()


func _end_level():
	Main.state = Main.STATE.GAMEPLAY_END
	$DepressionTimer.stop()
	$DelayTimer.stop()
	$HUDOverlay.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.game_paused = true
	player.hide()
	player.reparent(self)
	if rage_room != null:
		rage_room.queue_free()
	print_rich("[color=yellow]%s[/color]" % [Stats.stats])
