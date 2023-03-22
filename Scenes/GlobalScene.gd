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

var numeric_addresses: Array[Vector2] = [
	Vector2(1, 1), Vector2(2, 1), Vector2(3, 1), Vector2(4, 1),
	Vector2(1, 2), Vector2(2, 2), Vector2(3, 2), Vector2(4, 2),
]

var inbox: InOutBox
var inbox_items := [ "1", "2", "3", "10", "20" ]

var outbox: InOutBox
var expected_outbox_items := [ "3", "5", "7", "21", "41" ]

var _saved_objects: Array[WorldObject]
var objects: Array[WorldObject] = []

const _world_object_scene := preload("res://Scenes/WorldObject.tscn")

const known_commands := [
	{ scene = preload("res://Scenes/Commands/CommandGet.tscn"), name = "Get" },
	{ scene = preload("res://Scenes/Commands/CommandPut.tscn"), name = "Put" },
	{ scene = preload("res://Scenes/Commands/CommandAdd.tscn"), name = "Add" },
	{ scene = preload("res://Scenes/Commands/CommandSub.tscn"), name = "Sub" },
	{ scene = preload("res://Scenes/Commands/CommandBump.tscn"), name = "Bump" },
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
			for inbox_item in inbox_items:
				inbox.enqueue_object(inbox_item)
				
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
