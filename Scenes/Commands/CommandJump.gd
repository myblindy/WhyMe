extends CommandBase
class_name CommandJump

func _ready() -> void:
	var params := InitializeParameters.new("Jump")
	params.use_labels = true
	params.has_jump_types = true
	_initialize_actions(params)

func run() -> void:
	# test
	if jump_type == GlobalTypes.JumpType.NEGATIVE_VALUE:
		if bot.held_object_value.is_valid_int() and bot.held_object_value.to_int() >= 0:
			return
			
	# find jump target
	for command_index in len(GlobalScene.commands):
		var command: CommandBase = GlobalScene.commands[command_index]
		if command is CommandLabel and command.label_name == jump_to_label_name:
			GlobalScene.bots[0].forced_next_command_index = command_index
			break
		else:
			GlobalScene.set_error("Label name not found.", null, jump_to_label_name)
