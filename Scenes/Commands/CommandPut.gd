extends CommandBase
class_name CommandDrop

func _ready() -> void:
	_initialize_actions("Drop", true, false, true)

func run() -> void:
	if address_selected >= 0:
		await _move_to_address(address_selected)
	
	await _action_wait()

	if bot.held_object_value != "":
		GlobalScene.add_object(bot.position, bot.held_object_value)
		bot.held_object_value = ""
