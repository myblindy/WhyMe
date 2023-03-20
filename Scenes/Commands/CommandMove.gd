extends CommandBase
class_name CommandMove

@onready var menu_button := $MenuButton

var move_type := GlobalTypes.MoveType.MOVE_N:
	get:
		return move_type
	set(new_move_type):
		if move_type != new_move_type:
			move_type = new_move_type
			menu_button.text = menu_button.get_popup().get_item_text(move_type - 1)

func _menu_button_index_pressed(index: int) -> void:
	move_type = index + 1 as GlobalTypes.MoveType
	menu_button.text = menu_button.get_popup().get_item_text(index)
	pass

func _ready() -> void:
	menu_button.get_popup().index_pressed.connect(_menu_button_index_pressed)
	pass 
	
func run() -> void:
	await _move(move_type)

func stop() -> void:
	if bot.command_tween:
		bot.command_tween.kill()
		bot.command_tween = null
	bot.play_animation("idle-blink")
