extends Control
class_name CommandMove

@onready var menu_button := $MenuButton

var move_type = GlobalScene.MOVE_TYPE.MOVE_N:
	get:
		return move_type
	set(new_move_type):
		if move_type != new_move_type:
			move_type = new_move_type
			menu_button.text = menu_button.get_popup().get_item_text(move_type)

func _menu_button_index_pressed(index: int) -> void:
	move_type = index
	menu_button.text = menu_button.get_popup().get_item_text(index)
	pass

func _ready() -> void:
	menu_button.get_popup().index_pressed.connect(_menu_button_index_pressed)
	pass 
