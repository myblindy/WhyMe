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

signal selected_bot_changed
var selected_bot: Bot:
	get:
		return selected_bot
	set(new_selected_bot):
		var changed := selected_bot != new_selected_bot
		selected_bot = new_selected_bot
		if changed:
			selected_bot_changed.emit()

var numeric_addresses := {
	Vector2(0, 0): 2,
	Vector2(2, 3): 0,
	Vector2(2, 4): 1,
}

var _saved_objects: Array
var objects := []

var known_commands := [
	CommandMove,
	CommandPickup
]

var commands := []

signal run_state_changed
var run_state := false:
	get:
		return run_state
	set(new_run_state):
		var changed := run_state != new_run_state
		run_state = new_run_state
		if changed:
			run_state_changed.emit()
			
		for bot in bots:
			bot.current_command_index = -1
			
		if new_run_state:
			_saved_objects = [] + objects
		else:
			objects = _saved_objects
			
func find_object(position: Vector2) -> WorldObject:
	for object in objects:
		if object.position == position:
			return object
	return null

func remove_object(position: Vector2) -> void:
	for i in len(objects):
		if objects[i].position == position:
			objects.remove_at(i)
			return
