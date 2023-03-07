extends Control
class_name CommandPickup

@onready var _menu_button := $MenuButton

var drop_to_ground := true:
	get:
		return drop_to_ground
	set(new_drop_to_ground):
		if drop_to_ground != new_drop_to_ground or drop_to_address >= 0:
			drop_to_ground = new_drop_to_ground
			if drop_to_ground:
				drop_to_address = -1
			_set_menu_button_text()
			
var drop_to_address := -1:
	get:
		return drop_to_address
	set(new_drop_to_address):
		if drop_to_address != new_drop_to_address or drop_to_ground:
			drop_to_address = new_drop_to_address
			if drop_to_address >= 0:
				drop_to_ground = false
			_set_menu_button_text()

const _ground_label_name := "Gnd"

func _rebuild_menu():
	var popup: PopupMenu = _menu_button.get_popup()
	popup.clear()
	
	popup.add_item(_ground_label_name)
	for address in GlobalScene.numeric_addresses.values():
		popup.add_item(str(address + 1))
	
func _set_menu_button_text() -> void:
	_menu_button.text = "Gnd" if drop_to_ground else _menu_button.get_popup().get_item_text(drop_to_address + 1)
	
func _on_menu_button_index_pressed(index: int) -> void:
	if index == 0:
		drop_to_ground = true
	else:
		drop_to_address = index - 1
	_set_menu_button_text()

func _ready() -> void:
	_menu_button.get_popup().index_pressed.connect(_on_menu_button_index_pressed)
	
	_rebuild_menu()
	_set_menu_button_text()
