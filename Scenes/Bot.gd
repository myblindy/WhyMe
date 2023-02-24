extends Node2D
class_name Bot

signal current_command_index_changed
var current_command_index: int:
	get:
		return current_command_index
	set(new_current_command_index):
		var changed := current_command_index != new_current_command_index
		current_command_index = new_current_command_index
		if changed:
			current_command_index_changed.emit()
		_reset_action()
		held_object = null
	
func _ready() -> void:
	GlobalScene.run_state_changed.connect(_run_state_changed)
	
var _saved_position: Vector2
func _run_state_changed() -> void:
	if GlobalScene.run_state:
		_saved_position = position
	else:
		position = _saved_position
	
var held_object: WorldObject
	
var _action_percentage: float
var _action_running: bool
var _action_duration_sec: float
var _action_started_at_position: Vector2

func _reset_action() -> void:
	_action_percentage = 0
	_action_running = false
	_action_started_at_position = position
	
func _start_action(duration_sec: float) -> void:
	_action_running = true
	_action_duration_sec = duration_sec

func _process(delta) -> void:
	if GlobalScene.run_state:
		if not _action_running:
			if current_command_index < GlobalScene.commands.size() - 1:
				current_command_index += 1
				var next_command: Command = GlobalScene.commands[current_command_index]
				
				if next_command is CommandPickup:
					_start_action(1)
				elif next_command is CommandMove:
					_start_action(1)
		else:
			_action_percentage += delta / _action_duration_sec
			
			# handle movement
			var command: Command = GlobalScene.commands[current_command_index]
			
			if command is CommandMove:
				var delta_position: Vector2
				match command.move_type:
					GlobalScene.MOVE_TYPE.MOVE_S:
						delta_position = Vector2(0, 1)
					GlobalScene.MOVE_TYPE.MOVE_N:
						delta_position = Vector2(0, -1)
					GlobalScene.MOVE_TYPE.MOVE_E:
						delta_position = Vector2(1, 0)
					GlobalScene.MOVE_TYPE.MOVE_W:
						delta_position = Vector2(-1, 0)
				
				position = lerp(_action_started_at_position, _action_started_at_position + delta_position, clamp(_action_percentage, 0, 1))
			
			if _action_percentage >= 1:
				# command done
				
				if command is CommandPickup:
					held_object = GlobalScene.find_object(position)
					GlobalScene.remove_object(position)
				
				# and done, next cycle will start the next command
				_reset_action()
