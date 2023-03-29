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

var levels := [
	{
		"inbox_items": [ "1", "A", "C", "10" ],
		"expected_outbox_items": [ "1", "A", "C", "10" ],
		"name": "Simple Copy",
		"description": "Simply copy the input to the output",
		"numeric_addresses": []
	},
	{
		"inbox_items": [ "1", "2", "3", "10", "20" ],
		"expected_outbox_items": [ "3", "5", "7", "21", "41" ],
		"name": "Double Plus One",
		"description": "Double the input number and increment it by one",
		"numeric_addresses": [
			Vector2(1, 1), Vector2(2, 1), Vector2(3, 1), Vector2(4, 1),
			Vector2(1, 2), Vector2(2, 2), Vector2(3, 2), Vector2(4, 2),
		]
	}
]

signal current_level_index_changed
var current_level_index := -1:
	get:
		return current_level_index
	set(new_current_level_index):
		if current_level_index != new_current_level_index:
			current_level_index = new_current_level_index
			current_level_index_changed.emit()
			
var inbox: InOutBox
var outbox: InOutBox

var _saved_objects: Array[WorldObject]
var objects: Array[WorldObject] = []

const _world_object_scene := preload("res://Scenes/WorldObject.tscn")

const known_commands := [
	{ scene = preload("res://Scenes/Commands/CommandGet.tscn"), name = "Get" },
	{ scene = preload("res://Scenes/Commands/CommandPut.tscn"), name = "Put" },
	{ scene = preload("res://Scenes/Commands/CommandAdd.tscn"), name = "Add" },
	{ scene = preload("res://Scenes/Commands/CommandSub.tscn"), name = "Sub" },
	{ scene = preload("res://Scenes/Commands/CommandBump.tscn"), name = "Bump" },
	{ scene = preload("res://Scenes/Commands/CommandLabel.tscn"), name = "Label" },
	{ scene = preload("res://Scenes/Commands/CommandJump.tscn"), name = "Jump" },
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
			
			inbox.clear_objects()
			for inbox_item in levels[current_level_index].inbox_items:
				inbox.enqueue_object(inbox_item)
				
			# leave the error and outbox queue alone until we restart
			outbox.clear_objects()
			set_error()
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

# error stuff
signal error_changed

class ErrorType:
	var message: String
	var provided_value
	var expected_value
var _error := ErrorType.new()

func set_error(message: String = "", provided = null, expected = null) -> void:
	_error.message = message
	_error.expected_value = expected
	_error.provided_value = provided
	error_changed.emit()
	
	if message:
		GlobalScene.run_state = false	# stop the run

func get_error() -> ErrorType:
	return _error
