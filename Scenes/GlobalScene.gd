extends Node

enum TILE_TYPE
{
	NONE, TILE0, TILE1
}

enum MOVE_TYPE
{
	MOVE_N, MOVE_E, MOVE_S, MOVE_W
}

var bots := []

var numeric_addresses := {
	Vector2(0, 0): 2,
	Vector2(2, 3): 0,
	Vector2(2, 4): 1,
}

var objects := []

var known_commands := [
	CommandMove,
	CommandPickup
]

var commands := []

func _ready():
	pass 

signal current_command_index_changed
var _current_command_index: int:
	get:
		return _current_command_index
	set(new_current_command_index):
		_current_command_index = new_current_command_index
		current_command_index_changed.emit()
var current_command_index:
	get:
		return _current_command_index

signal run_state_changed
var run_state := false:
	get:
		return run_state
	set(new_run_state):
		run_state = new_run_state
		run_state_changed.emit()
		_current_command_index = 0
		
func _process(delta: float) -> void:
	if run_state:
		if current_command_index >= commands.size():
			run_state = false
		else:
			var command: Command = commands[current_command_index]
			
			if command is CommandPickup:
				pass
		
