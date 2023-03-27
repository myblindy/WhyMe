extends Node2D
class_name Bot

@onready var _animation_player := $AnimationPlayer
@onready var _held_world_object := $HeldWorldObject

signal current_command_index_changed
var current_command_index := -1:
	get:
		return current_command_index
	set(new_current_command_index):
		if current_command_index != new_current_command_index:
			current_command_index = new_current_command_index
			current_command_index_changed.emit()
		
var command_tween: Tween

func play_animation(animation_name: String) -> void:
	_animation_player.play(animation_name)
	
func _ready() -> void:
	GlobalScene.run_state_changed.connect(_run_state_changed)
	_held_world_object.scale = Vector2(0.3, 0.3)
	
var _saved_position: Vector2
func _run_state_changed() -> void:
	if GlobalScene.run_state:
		_start_run()
	else:
		_stop_run()

var forced_next_command_index	# for jumps
var current_command: CommandBase
func _start_run() -> void:
	#save old state
	_saved_position = position
	forced_next_command_index = null
	
	#main bot loop
	while GlobalScene.run_state:
		if forced_next_command_index != null:
			current_command_index = forced_next_command_index
			forced_next_command_index = null
		else:
			current_command_index += 1
			
		# defer this check until after we set the forced index
		if current_command_index >= GlobalScene.commands.size():
			break
			
		current_command = GlobalScene.commands[current_command_index]
		await current_command.run()
		
func _stop_run() -> void:
	#restore old state
	position = _saved_position
	held_object_value = ""
	
	if current_command:
		current_command.stop()
		current_command = null
	
var held_object_value: String:
	get:
		return _held_world_object.value
	set(new_held_object_value):
		if held_object_value != new_held_object_value:
			_held_world_object.value = new_held_object_value
			
			if held_object_value != "":
				_held_world_object.show()
			else:
				_held_world_object.hide()
