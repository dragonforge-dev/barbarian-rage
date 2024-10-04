extends Object

class_name Stats

enum QuantLevel {
	NONE,
	PEAKS,
	NAHN,
	CRON,
	MILS,
	QUANT
}

static var stats = {
	"Small Barrel": 0,
	"Small Box": 0,
	"Large Barrel": 0,
	"Large Box": 0,
	"Barrel Stack": 0,
	"Quant Collected": 0,
	"Succumbed To Depression": 0,
	"Triumphs Over Depression": 0,
	"Highest Quant Level": 0,
	"Game Running Time": 0.0,
	"Best Game Completeion Time": 0.0,
}


# Connect destructible death signals
static func connect_death(destructible):
	destructible.death.connect(_on_item_destroyed)


static func _on_item_destroyed(name: String):
	stats[name] += 1


# Connect player collect quant signal
static func connect_quant(player):
	player.peaksChanged.connect(collect_quant)
	

static func collect_quant(amount: int):
	stats["Quant Collected"] += amount
	if stats["Quant Collected"] > pow(10, stats["Highest Quant Level"]):
		add_quant_level()


static func depressed_again():
	stats["Succumbed To Depression"] += 1


static func triumph():
	stats["Triumphs Over Depression"] += 1


static func add_quant_level():
	stats["Highest Quant Level"] += 1


static func add_game_running_time(time: float):
	stats["Game Running Time"] += time


static func add_game_completion_time(time: float):
	var current_record = stats["Best Game Completeion Time"]
	if time < current_record:
		stats["Best Game Completeion Time"] = time
