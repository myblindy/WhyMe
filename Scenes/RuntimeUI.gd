extends Control

@onready var _all_command_list := $RootContainer/VBoxContainer/HBoxContainer/AllCommandList
@onready var _program_list := $RootContainer/VBoxContainer/HBoxContainer/MarginContainer/ProgramList

@onready var _run_button := $RootContainer/VBoxContainer/HBoxContainer2/RunButton
@onready var _stop_button := $RootContainer/VBoxContainer/HBoxContainer2/StopButton

const _command_decoration_scene := preload("res://Scenes/Commands/CommandDecoration.tscn")

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
			var command_decoration: CommandDecoration = _program_list.get_child(i)
			command_decoration.is_current = i - 1 == GlobalScene.selected_bot.current_command_index if GlobalScene.run_state else false
			command_decoration.can_move_up = i > 1
			command_decoration.can_move_down = i < _program_list.get_child_count() - 1

func _run_state_changed() -> void:
	_run_button.disabled = GlobalScene.run_state
	_stop_button.disabled = not GlobalScene.run_state
	_all_command_list.visible = not GlobalScene.run_state
	_update_all_current_markers()
	
func _current_command_index_changed() -> void:
	_update_all_current_markers()

func _add_command(command_template) -> void:
	var command = command_template.scene.instantiate()
	command.bot = GlobalScene.bots[0]
	GlobalScene.commands.append(command)
	
	var scene: CommandDecoration = _command_decoration_scene.instantiate()
	_program_list.add_child(scene)
	scene.command = command
	scene.up_pressed.connect(_on_command_decoration_up_pressed.bind(scene))
	scene.down_pressed.connect(_on_command_decoration_down_pressed.bind(scene))
	scene.delete_pressed.connect(_on_command_decoration_del_pressed.bind(scene))
	
	_update_all_current_markers()

func _on_command_decoration_del_pressed(command_decoration: CommandDecoration) -> void:	
	_program_list.remove_child(command_decoration)
	_update_all_current_markers()

func _on_command_decoration_up_pressed(command_decoration: CommandDecoration) -> void:
	var index = command_decoration.get_index()
	_program_list.move_child(command_decoration, index - 1)
	
	var prev_command = GlobalScene.commands[index - 2]
	GlobalScene.commands[index - 2] = GlobalScene.commands[index - 1]
	GlobalScene.commands[index - 1] = prev_command
	
	_update_all_current_markers()
	
func _on_command_decoration_down_pressed(command_decoration: CommandDecoration) -> void:
	var index = command_decoration.get_index()
	_program_list.move_child(command_decoration, index + 1)
	
	var prev_command = GlobalScene.commands[index - 1]
	GlobalScene.commands[index - 1] = GlobalScene.commands[index]
	GlobalScene.commands[index] = prev_command
	
	_update_all_current_markers()

func _on_run_button_pressed() -> void:
	GlobalScene.run_state = true

func _on_stop_button_pressed() -> void:
	GlobalScene.run_state = false
