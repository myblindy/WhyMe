extends Control

@onready var _all_command_list := $RootContainer/HBoxContainer/AllCommandList
@onready var _program_list := $RootContainer/HBoxContainer/MarginContainer/ProgramList

func _ready() -> void:
	for command_template in GlobalScene.known_commands:
		var button := Button.new()
		_all_command_list.add_child(button)
		
		button.text = command_template.name
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.pressed.connect(_add_command.bind(command_template))
		
func _add_command(command_template) -> void:
	var command = command_template.new()
	GlobalScene.commands.append(command)
	
	var scene = command_template.scene.instantiate()
	scene.command = command
	_program_list.add_child(scene)
	pass
