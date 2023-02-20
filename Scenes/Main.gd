extends Node2D

const tile_count = Vector2(7, 7)
var tileSize: Vector2
var realTileSize: Vector2
var windowSize: Vector2

const botTemplate = preload("res://Scenes/Bot.tscn")
var bots = []

const ground_tile_template = preload("res://Scenes/GroundTile.tscn")

var inbox
var outbox

func _ready():
	windowSize = get_viewport().size
	
	# bots
	var first = true
	var offset: Vector2
	for pos in [Vector2(0, 0), Vector2(1, 0), Vector2(6, 0), Vector2(0, 6), Vector2(6, 6)]:
		var bot = botTemplate.instantiate()
		add_child(bot)
		bots.append(bot)
		
		if first:
			first = false
			tileSize = windowSize / tile_count
			realTileSize = tileSize
			
			if tileSize.x > tileSize.y:
				tileSize = Vector2(tileSize.y, tileSize.y)
			else:
				tileSize = Vector2(tileSize.x, tileSize.x)
				
			offset = windowSize - tileSize * tile_count
		
		bot.position = offset + (pos + Vector2(0.5, 0.5)) * tileSize
		bot.scale *= realTileSize.y
		bot.z_index = 1
		
	# tiles
	for y in tile_count.y:
		for x in tile_count.x:
			var tile = ground_tile_template.instantiate()
			add_child(tile)
			
			tile.position = offset + Vector2(x + 0.5, y + 0.5) * tileSize
			tile.scale *= realTileSize.y
			tile.tile_kind = GlobalScene.TILE_TYPE.TILE0 if int(x * tile_count.x + y) % 2 == 0 else GlobalScene.TILE_TYPE.TILE1
			tile.z_index = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
