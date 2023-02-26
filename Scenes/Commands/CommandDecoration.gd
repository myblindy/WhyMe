extends HBoxContainer
class_name CommandDecoration

@onready var _current_check_box := $CurrentCheckBox
@onready var _up_button := $UpButton
@onready var _down_button := $DownButton
@onready var _command_root := $CommandRoot

var command: Command:
	get: 
		return command
	set(new_command):
		if command != new_command:
			command = new_command
			
			if _command_root.get_child_count() > 0:
				_command_root.remove_child(_command_root.get_child(0))
			
			var command_scene: Control = command.scene.instantiate()
			command_scene.command = command
			_command_root.add_child(command_scene)
			
var is_current: bool:
	get:
		return is_current
	set(new_is_current):
		is_current = new_is_current
		_current_check_box.button_pressed = is_current
		
var can_move_up := true:
	get:
		return can_move_up
	set(new_can_move_up):
		can_move_up = new_can_move_up
		_up_button.disabled = not can_move_up

var can_move_down := true:
	get:
		return can_move_down
	set(new_can_move_down):
		can_move_down = new_can_move_down
		_down_button.disabled = not can_move_down
		
signal up_pressed
signal down_pressed
signal delete_pressed

func _ready() -> void:
	pass # Replace with function body.

func _on_up_button_pressed() -> void:
	up_pressed.emit()

func _on_down_button_pressed() -> void:
	down_pressed.emit()

func _on_delete_button_pressed() -> void:
	delete_pressed.emit()
