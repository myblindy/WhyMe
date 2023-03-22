extends CommandBase
class_name CommandBump

func _ready() -> void:
	_initialize_actions("Bump", false, false, false, true)

func run() -> void:
	await _action_wait()
	
	var delta: int
	match plus_minus_selected:
		0:
			delta = 1
		1:
			delta = 0
	
	if bot.held_object_value.is_valid_int():
		bot.held_object_value = str(bot.held_object_value.to_int() + delta)
	elif bot.held_object_value == "":
		bot.held_object_value = str(delta)
