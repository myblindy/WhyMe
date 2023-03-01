extends Node2D
class_name Bot

@onready var _animation_player := $AnimationPlayer
@onready var _held_world_object := $HeldWorldObject

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
	
func _ready() -> void:
	GlobalScene.run_state_changed.connect(_run_state_changed)
	_held_world_object.scale = Vector2(0.3, 0.3)
	
var _saved_position: Vector2
func _run_state_changed() -> void:
	if GlobalScene.run_state:
		_saved_position = position
	else:
		position = _saved_position
		held_object = null
	
var held_object: WorldObject:
	get:
		return held_object
	set(new_held_object):
		if held_object != new_held_object:
			held_object = new_held_object
			
			if held_object:
				_held_world_object.value = held_object.value
				_held_world_object.show()
			else:
				_held_world_object.hide()
	
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
	
func _get_next_move_type(current: Vector2, target: Vector2):
	if position.x > target.x:
		return GlobalScene.MOVE_TYPE.MOVE_W
	elif position.x < target.x:
		return GlobalScene.MOVE_TYPE.MOVE_E
	elif position.y > target.y:
		return GlobalScene.MOVE_TYPE.MOVE_N
	else:
		return GlobalScene.MOVE_TYPE.MOVE_S
	return null
	
func _get_command_target_position(command):
	if command is CommandPickup and command.drop_to_address:
		return GlobalScene.numeric_addresses.keys()[command.drop_to_address]
	return null

var _current_move_type
func _process(delta) -> void:
	if GlobalScene.run_state:
		if not _action_running:
			if current_command_index < GlobalScene.commands.size() - 1:
				current_command_index += 1
				var next_command = GlobalScene.commands[current_command_index]
				
				if (next_command is CommandPickup or next_command is CommandDrop) and next_command.drop_to_ground:
					_start_action(1)
					_current_move_type = null
				else:
					_start_action(1)
					
					if next_command is CommandMove:
						_current_move_type = next_command.move_type
					else:
						var cp := next_command as CommandPickup
						
						if cp and cp.drop_to_address >= 0:
							var target: Vector2 = GlobalScene.numeric_addresses.keys()[cp.drop_to_address]
							_current_move_type = _get_next_move_type(position, target)
						else:
							_current_move_type = null
					
					match _current_move_type:
						GlobalScene.MOVE_TYPE.MOVE_S:
							_animation_player.play("walk-down")
						GlobalScene.MOVE_TYPE.MOVE_N:
							_animation_player.play("walk-up")
						GlobalScene.MOVE_TYPE.MOVE_E:
							_animation_player.play("walk-right")
						GlobalScene.MOVE_TYPE.MOVE_W:
							_animation_player.play("walk-left")
					
		else:
			_action_percentage = clamp(_action_percentage + delta / _action_duration_sec, 0, 1)
			
			# handle movement
			var command = GlobalScene.commands[current_command_index]
			
			if _current_move_type != null:
				var delta_position: Vector2
				match _current_move_type:
					GlobalScene.MOVE_TYPE.MOVE_S:
						delta_position = Vector2(0, 1)
					GlobalScene.MOVE_TYPE.MOVE_N:
						delta_position = Vector2(0, -1)
					GlobalScene.MOVE_TYPE.MOVE_E:
						delta_position = Vector2(1, 0)
					GlobalScene.MOVE_TYPE.MOVE_W:
						delta_position = Vector2(-1, 0)
				
				position = lerp(_action_started_at_position, _action_started_at_position + delta_position, _action_percentage)
			
			if _action_percentage >= 1:
				# command done
				
				var action_done := false
				
				if command is CommandPickup:
					if command.drop_to_address:
						var target: Vector2 = _get_command_target_position(command) 
						_current_move_type = _get_next_move_type(position, target)
					
					if command.drop_to_ground or _current_move_type == null:
						var object: WorldObject = GlobalScene.find_object(position)
						if object:
							GlobalScene.remove_object(position)
							held_object = object
						action_done = true
				elif command is CommandDrop:
					if held_object:
						GlobalScene.remove_object(position)
						GlobalScene.add_object(position, held_object)
						held_object = null
					action_done = true
				elif command is CommandMove:
					action_done = true
					
				# we're either done with this move or we still have pathfinding nodes to do
				if not action_done:
					var target: Vector2 = _get_command_target_position(command)
					_current_move_type = _get_next_move_type(position, target)
					
					if _current_move_type != null:
						_action_started_at_position = position
						_action_percentage = 0
					else:
						action_done = true
						
				if action_done:
					_animation_player.play("idle-blink")
					_reset_action()
