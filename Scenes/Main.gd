extends Node2D

@onready var _game_board_root := $GameBoardRoot

const tile_count := Vector2(7, 7)
var tile_size: Vector2
var real_tile_size: Vector2
var window_size: Vector2

const _bot_template := preload("res://Scenes/Bot.tscn")
const _ground_tile_template := preload("res://Scenes/GroundTile.tscn")
const _object_template := preload("res://Scenes/WorldObject.tscn")

var inbox
var outbox

func _add_new_object(location: Vector2, offset: Vector2, value: String):
	var object := _object_template.instantiate()
	GlobalScene.objects.append(object)
	_game_board_root.add_child(object)
	
	object.value = value
	object.z_index = 5
	object.position = location
	object.scale *= 0.8
	
func _objects_changed() -> void:
	for node in _game_board_root.get_children():
		if node is WorldObject:
			if GlobalScene.objects.find(node) >= 0:
				node.show()
			else:
				node.hide()

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
			tile.tile_kind = GlobalScene.TILE_TYPE.TILE0 if int(x * tile_count.x + y) % 2 == 0 else GlobalScene.TILE_TYPE.TILE1
			tile.z_index = 0
			
			var numeric_address: int = GlobalScene.numeric_addresses.get(Vector2(x, y), -1)
			if(numeric_address >= 0):
				tile.numeric_address = numeric_address

	# objects
	_add_new_object(Vector2(1, 1), offset, "A")
	_add_new_object(Vector2(2, 1), offset, "B")
	_add_new_object(Vector2(3, 1), offset, "C")
	_add_new_object(Vector2(4, 1), offset, "D")
	
	# set up the game board transform
	_game_board_root.position = offset + Vector2(0.5, 0.5) * tile_size
	_game_board_root.scale = Vector2(real_tile_size.y, real_tile_size.y)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
