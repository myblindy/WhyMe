extends CommandBase
class_name CommandAdd

func _ready() -> void:
	var params := InitializeParameters.new("Add")
	params.addresses = true
	_initialize_actions(params)

func run() -> void:
	if address_selected >= 0:
		await _move_to_address(address_selected)
	
	await _action_wait()
	
	var ground_object = GlobalScene.find_object(bot.position)
	if ground_object and ground_object.value.is_valid_int() and bot.held_object_value.is_valid_int():
		bot.held_object_value = str(int(bot.held_object_value) + int(ground_object.value))
	elif ground_object and ground_object.value.is_valid_int() and bot.held_object_value == "":
		bot.held_object_value = ground_object.value
