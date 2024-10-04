extends HSlider

@export var audio_bus_name : String

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)


func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus))
	self.value_changed.connect(_on_value_changed)
	self.gui_input.connect(_on_gui_input)


func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(new_value))


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		Sounds.play(get_owner().volume_confirm_sound, Sounds.string_to_channel(self.name))
