extends Control

@onready var menu_button := $MenuButton
var command: CommandMove

func _menu_button_index_pressed(index: int) -> void:
	command.move_type = index
	menu_button.text = menu_button.get_popup().get_item_text(index)
	pass

func _ready() -> void:
	menu_button.get_popup().index_pressed.connect(_menu_button_index_pressed)
	pass 
