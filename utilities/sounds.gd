extends Node

class_name Sounds

signal _now_playing(song: Song)

enum CHANNEL {
	MASTER,
	MUSIC,
	SFX,
	DIALOGUE
}


static var audio_stream_player = {
	"Music" = AudioStreamPlayer.new(),
}

static var singleton := Sounds.new()
static var now_playing := Signal(singleton._now_playing)


static func connect_players():
	for player in audio_stream_player:
		Engine.get_main_loop().current_scene.add_child(audio_stream_player[player])
	audio_stream_player["Music"].set_bus("Music")

static func play_sound_effect(sound: AudioStream):
	play(sound, CHANNEL.SFX)


static func play_music(sound: Song):
	if sound.song == null:
		push_error("%s song is empty. No AudioStream assigned." % [sound.resource_path])
	audio_stream_player["Music"].set_stream(sound.song)
	audio_stream_player["Music"].play()
	print_rich("Song Playing: %s\nby %s" % [sound.title, sound.artist])
	print_rich("Album: %s\nAlbum Link %s" % [sound.album, sound.album_link])
	now_playing.emit(sound)


static func pause_music():
	audio_stream_player["Music"].stream_paused = true


static func unpause_music():
	audio_stream_player["Music"].stream_paused = false


static func play(sound: AudioStream, channel: CHANNEL):
	if sound == null:
			return
	var player = AudioStreamPlayer.new()
	Engine.get_main_loop().current_scene.add_child(player)
	player.set_bus(channel_to_string(channel))
	player.set_stream(sound)
	player.play()

	var timer = LifetimeTimer.new(player)
	timer.wait_time = sound.get_length()
	Engine.get_main_loop().current_scene.add_child(timer)
	timer.start()


static func channel_to_string(channel: CHANNEL):
	match channel:
		CHANNEL.MASTER:
			return "Master"
		CHANNEL.MUSIC:
			return "Music"
		CHANNEL.SFX:
			return "SFX"
		CHANNEL.DIALOGUE:
			return "Dialogue"


static func string_to_channel(value: String):
	match value:
		"Master":
			return CHANNEL.MASTER
		"Music":
			return CHANNEL.MUSIC
		"SFX":
			return CHANNEL.SFX
		"Dialogue":
			return CHANNEL.DIALOGUE
