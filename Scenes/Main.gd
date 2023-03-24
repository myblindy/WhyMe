extends Node2D

@onready var _game_board_root := $GameBoardRoot

const tile_count := Vector2(7, 7)
var tile_size: Vector2
var real_tile_size: Vector2
var window_size: Vector2

const _bot_template := preload("res://Scenes/Bot.tscn")
const _ground_tile_template := preload("res://Scenes/GroundTile.tscn")
const _object_template := preload("res://Scenes/WorldObject.tscn")
const _in_out_box_scene := preload("res://Scenes/InOutBox.tscn")

var inbox
var outbox

func _add_new_object(location: Vector2, value: String):
	var object := _object_template.instantiate()
	GlobalScene.objects.append(object)
	_game_board_root.add_child(object)
	
	object.value = value
	object.z_index = 5
	object.position = location
	object.scale *= 0.8
	
func _objects_changed() -> void:
	var seen := {}
	for node in _game_board_root.get_children():
		if node is WorldObject:
			var found_index := GlobalScene.objects.find(node)
			if found_index >= 0:
				node.show()
				seen[found_index] = null
			else:
				node.hide()
				
	# any left over objects have to be added to the world
	for object_index in len(GlobalScene.objects):
		if not seen.has(object_index):
			var object: WorldObject = GlobalScene.objects[object_index]
			_add_new_object(object.position, object.value)

func _ready() -> void:
	window_size = get_viewport().size
	GlobalScene.objects_changed.connect(_objects_changed)
	
	# bots
	var first := true
	var offset: Vector2
	for pos in [Vector2(0, 0)]:
		var bot := _bot_template.instantiate()
		_game_board_root.add_child(bot)
		GlobalScene.bots.append(bot)
		
		if first:
			first = false
			tile_size = window_size / tile_count
			real_tile_size = tile_size
			
			if tile_size.x > tile_size.y:
				tile_size = Vector2(tile_size.y, tile_size.y)
			else:
				tile_size = Vector2(tile_size.x, tile_size.x)
				
			offset = window_size - tile_size * tile_count
		
		bot.position = pos #offset + (pos + Vector2(0.5, 0.5)) * tile_size
		bot.z_index = 10
	GlobalScene.selected_bot = GlobalScene.bots[0]
		
	# tiles
	for y in tile_count.y:
		for x in tile_count.x:
			var tile := _ground_tile_template.instantiate()
			_game_board_root.add_child(tile)
			
			tile.position = Vector2(x, y)
			tile.tile_kind = GlobalTypes.TileType.TILE0 if int(x * tile_count.x + y) % 2 == 0 else GlobalTypes.TileType.TILE1
			tile.z_index = 0
			
			var numeric_address := GlobalScene.numeric_addresses.find(Vector2(x, y))
			if(numeric_address >= 0):
				tile.numeric_address = numeric_address

	# objects
	_add_new_object(Vector2(1, 1), "3")
	_add_new_object(Vector2(2, 1), "5")
	_add_new_object(Vector2(3, 1), "C")
	_add_new_object(Vector2(4, 1), "D")
	
	# inbox and outbox
	const inbox_length := 4
	GlobalScene.inbox = _in_out_box_scene.instantiate()
	GlobalScene.inbox.position = Vector2(0, tile_count.y - inbox_length)
	GlobalScene.inbox.setup(inbox_length, true)
	_game_board_root.add_child(GlobalScene.inbox)
	
	GlobalScene.outbox = _in_out_box_scene.instantiate()
	GlobalScene.outbox.position = Vector2(tile_count.x - 1, tile_count.y - inbox_length)
	GlobalScene.outbox.setup(inbox_length, false)
	_game_board_root.add_child(GlobalScene.outbox)
	
	# outbox result check
	GlobalScene.outbox.object_enqueued.connect(_outbox_object_enqueued)

	# set up the game board transform
	_game_board_root.position = offset + Vector2(0.5, 0.5) * tile_size
	_game_board_root.scale = Vector2(real_tile_size.y, real_tile_size.y)

func _outbox_object_enqueued() -> void:
	var current_objects := GlobalScene.outbox.get_objects()
	if len(current_objects) <= len(GlobalScene.expected_outbox_items):
		if current_objects != GlobalScene.expected_outbox_items.slice(0, len(current_objects)):
			GlobalScene.set_error("Wrong item sent to outbox", current_objects[-1], GlobalScene.expected_outbox_items[len(current_objects) - 1])
