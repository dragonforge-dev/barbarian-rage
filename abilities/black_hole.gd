extends Area3D

@export var strength: float = 0.05


var pickups: Array[Pickup]
var speeds: Array[float]


func _ready() -> void:
	area_entered.connect(_on_area_enter)


func _process(delta: float) -> void:
	var current_position = global_position
	for i in range(pickups.size() -1, -1, -1):
		var pickup = pickups[i]
		if pickup == null:
			pickups.remove_at(i)
			speeds.remove_at(i)
		elif pickup.global_position.distance_to(current_position) > speeds[i]:
			speeds[i] += strength * delta
			pickup.position += pickup.global_position.direction_to(current_position) * speeds[i]
		else:
			pickup.global_position = current_position


func set_range(black_hole_range: float) -> void:
	$Range.shape.radius = black_hole_range


func get_range() -> float:
	return $Range.shape.radius


func _on_area_enter(area : Area3D) -> void:
	var pickup = area.get_parent() as Pickup
	pickups.append(pickup)
	speeds.append(strength)
	pickup.set_physics_process(false)
