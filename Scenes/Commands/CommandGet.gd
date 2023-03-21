extends CommandBase
class_name CommandGet

func _ready() -> void:
	_initialize_actions("Get", true, true, false)

func run() -> void:
	if address_selected >= 0:
		await _move_to_address(address_selected)
	
	await _action_wait()
	
	var object: WorldObject = GlobalScene.find_object(bot.position)
	if object:
		GlobalScene.remove_object(bot.position)
		bot.held_object_value = object.value
