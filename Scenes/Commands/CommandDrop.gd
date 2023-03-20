extends CommandBase
class_name CommandDrop

const drop_to_ground := true

func run() -> void:
	await _action_wait()

	if bot.held_object_value != "":
		GlobalScene.add_object(bot.position, bot.held_object_value)
		bot.held_object_value = ""
