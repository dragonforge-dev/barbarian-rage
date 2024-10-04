extends CanvasLayer

signal check_levels

@export var player: CharacterBody3D
@export var depression_timer: Timer


func show_time_up_label():
	$MarginContainer/TimeUpLabel.show()


func hide_time_up_label():
	$MarginContainer/TimeUpLabel.hide()
	$MarginContainer/LevelCompleteLabel.hide()


func start_level(depression_resistance: float):
	%DepressionProgressBar.initialize(depression_resistance)
	update_levels()
	hide_time_up_label()
	show()


func pause_game():
	pass


func unpause_game():
	update_levels()


func show_level_complete_label() -> void:
	$MarginContainer/LevelCompleteLabel.show()


func update_levels():
	check_levels.emit()
	for node in get_tree().get_nodes_in_group("hud_ability"):
		node.update_level(player.ability_levels[node.get_name()])
