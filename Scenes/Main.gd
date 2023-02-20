extends Node2D

const tile_count := Vector2(7, 7)
var tile_size: Vector2
var real_tile_size: Vector2
var window_size: Vector2

const bot_template := preload("res://Scenes/Bot.tscn")
var bots := []

const ground_tile_template := preload("res://Scenes/GroundTile.tscn")
var _numeric_addresses := {
	Vector2(0, 0): 2,
	Vector2(2, 3): 0,
	Vector2(2, 4): 1,
}

const object_template := preload("res://Scenes/Object.tscn")
var _objects := []

var inbox
var outbox

func _add_new_object(location: Vector2, offset: Vector2, value: String):
	var object := object_template.instantiate()
	add_child(object)
	object.value = value
	object.z_index = 5
	object.position = offset + (location + Vector2(0.5, 0.5)) * tile_size
	object.scale *= real_tile_size.y * 0.8

func _ready():
	window_size = get_viewport().size
	
	# bots
	var first := true
	var offset: Vector2
	for pos in [Vector2(0, 0), Vector2(1, 0), Vector2(6, 0), Vector2(0, 6), Vector2(6, 6)]:
		var bot := bot_template.instantiate()
		add_child(bot)
		bots.append(bot)
		
		if first:
			first = false
			tile_size = window_size / tile_count
			real_tile_size = tile_size
			
			if tile_size.x > tile_size.y:
				tile_size = Vector2(tile_size.y, tile_size.y)
			else:
				tile_size = Vector2(tile_size.x, tile_size.x)
				
			offset = window_size - tile_size * tile_count
		
		bot.position = offset + (pos + Vector2(0.5, 0.5)) * tile_size
		bot.scale *= real_tile_size.y
		bot.z_index = 10
		
	# tiles
	for y in tile_count.y:
		for x in tile_count.x:
			var tile := ground_tile_template.instantiate()
			add_child(tile)
			
			tile.position = offset + Vector2(x + 0.5, y + 0.5) * tile_size
			tile.scale *= real_tile_size.y
			tile.tile_kind = GlobalScene.TILE_TYPE.TILE0 if int(x * tile_count.x + y) % 2 == 0 else GlobalScene.TILE_TYPE.TILE1
			tile.z_index = 0
			
			var numeric_address: int = _numeric_addresses.get(Vector2(x, y), -1)
			if(numeric_address >= 0):
				tile.numeric_address = numeric_address

	# objects
	_add_new_object(Vector2(1, 1), offset, "A")
	_add_new_object(Vector2(2, 1), offset, "B")
	_add_new_object(Vector2(3, 1), offset, "C")
	_add_new_object(Vector2(4, 1), offset, "D")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
