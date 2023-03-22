extends CommandBase
class_name CommandGet

func _ready() -> void:
	_initialize_actions("Get", true, true, false, false)

func run() -> void:
	await _move()	
	
	if address_selected >= 0:
		await _action_wait()
		var object: WorldObject = GlobalScene.find_object(bot.position)
		if object:
			GlobalScene.remove_object(bot.position)
			bot.held_object_value = object.value
	elif inbox_selected:
		await GlobalScene.inbox.wait_for_interaction_available()
		await _action_wait()
		bot.held_object_value = GlobalScene.inbox.dequeue_object()
