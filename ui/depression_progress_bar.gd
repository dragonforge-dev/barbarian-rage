extends ProgressBar

@onready var depression_timer = $"../../../..".depression_timer


func initialize(depression_resistance: float) -> void:
	max_value = depression_resistance
	print_rich("Depression Bar Max Resistance: %s" % [max_value])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	value = depression_timer.time_left
