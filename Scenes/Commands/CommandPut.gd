extends CommandBase
class_name CommandDrop

func _ready() -> void:
	var params := InitializeParameters.new("Put")
	params.addresses = true
	params.outbox = true
	_initialize_actions(params)

func run() -> void:
	await _move()
	
	if address_selected >= 0:
		await _action_wait()
		if bot.held_object_value != "":
			GlobalScene.add_object(bot.position, bot.held_object_value)
			bot.held_object_value = ""
	elif outbox_selected:
		await GlobalScene.outbox.wait_for_interaction_available()
		await _action_wait()
		if bot.held_object_value != "":
			GlobalScene.outbox.enqueue_object(bot.held_object_value)
			bot.held_object_value = ""