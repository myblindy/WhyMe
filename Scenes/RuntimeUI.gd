extends Control

@onready var _all_command_list := $RootContainer/VBoxContainer/HBoxContainer/AllCommandList
@onready var _program_list := $RootContainer/VBoxContainer/HBoxContainer/MarginContainer/ProgramList

@onready var _run_button := $RootContainer/VBoxContainer/HBoxContainer2/RunButton
@onready var _stop_button := $RootContainer/VBoxContainer/HBoxContainer2/StopButton

func _ready() -> void:
	GlobalScene.run_state_changed.connect(_run_state_changed)
	GlobalScene.selected_bot_changed.connect(_selected_bot_changed)
	
	for command_template in GlobalScene.known_commands:
		var button := Button.new()
		_all_command_list.add_child(button)
		
		button.text = command_template.name
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.pressed.connect(_add_command.bind(command_template))
		
func _selected_bot_changed() -> void:
	GlobalScene.selected_bot.current_command_index_changed.connect(_current_command_index_changed)
	_current_command_index_changed()
		
func _update_all_current_markers() -> void:
	for i in _program_list.get_child_count():
		if i > 0:
			_program_list.get_child(i).get_child(0).button_pressed = i - 1 == GlobalScene.selected_bot.current_command_index
		
func _run_state_changed() -> void:
	_run_button.disabled = GlobalScene.run_state
	_stop_button.disabled = not GlobalScene.run_state
	_update_all_current_markers()
	
func _current_command_index_changed() -> void:
	_update_all_current_markers()

func _add_command(command_template) -> void:
	var command = command_template.new()
	GlobalScene.commands.append(command)
	
	var container := HBoxContainer.new()
	_program_list.add_child(container)
	
	var check = CheckBox.new()
	check.disabled = true
	container.add_child(check)
		
	var scene = command_template.scene.instantiate()
	scene.command = command
	container.add_child(scene)
	pass

func _on_run_button_pressed() -> void:
	GlobalScene.run_state = true

func _on_stop_button_pressed() -> void:
	GlobalScene.run_state = false
