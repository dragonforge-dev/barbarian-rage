extends Control


func _ready() -> void:
	Sounds.now_playing.connect(_on_new_song_playing)

func set_song_information(song: Song) -> void:
	%SongTitle.text = song.title
	%Artist.text = song.artist
	%Album.text = "[url=%s]%s[/url]" % [song.album_link, song.album]

func _on_new_song_playing(song: Song) -> void:
	print("Song Playing Signal Received")
	set_song_information(song)


func _on_album_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
