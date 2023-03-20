extends Node

var bots: Array[Bot] = []

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
	Vector2(2, 3): 0,
	Vector2(2, 4): 1,
	Vector2(0, 0): 2,
}

var _saved_objects: Array[WorldObject]
var objects: Array[WorldObject] = []

const _world_object_scene := preload("res://Scenes/WorldObject.tscn")

const known_commands := [
	{ scene = preload("res://Scenes/Commands/CommandMove.tscn"), name = "Move" },
	{ scene = preload("res://Scenes/Commands/CommandPickup.tscn"), name = "Pickup" },
	{ scene = preload("res://Scenes/Commands/CommandDrop.tscn"), name = "Drop" },
	{ scene = preload("res://Scenes/Commands/CommandAdd.tscn"), name = "Add" },
]

var commands: Array[CommandBase] = []

signal run_state_changed
var run_state := false:
	get:
		return run_state
	set(new_run_state):		
		for bot in bots:
			bot.current_command_index = -1
			
		if run_state != new_run_state:
			run_state = new_run_state
			run_state_changed.emit()
			
		if new_run_state:
			_saved_objects = []
			_saved_objects.append_array(objects)
		else:
			objects = _saved_objects
			objects_changed.emit()
			
func find_object(position: Vector2) -> WorldObject:
	for object in objects:
		if object.position == position:
			return object
	return null

signal objects_changed
func remove_object(position: Vector2) -> void:
	for i in len(objects):
		if objects[i].position == position:
			objects.remove_at(i)
			objects_changed.emit()
			return

func add_object(position: Vector2, object_value: String) -> void:
	var existing_object := find_object(position)
	if existing_object:
		existing_object.value = object_value
	else:
		var new_object := _world_object_scene.instantiate()
		new_object.position = position
		new_object.value = object_value
		
		objects.append(new_object)
		objects_changed.emit()
