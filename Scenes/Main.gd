extends Node2D

const tileCount = Vector2(7, 7)
var tileSize: Vector2
var windowSize: Vector2

var botTemplate = preload("res://Scenes/Bot.tscn")
var bots = []

func _ready():
	windowSize = get_viewport().size
	
	var first = true
	for pos in [Vector2(0, 0), Vector2(1, 0), Vector2(6, 0), Vector2(0, 6), Vector2(6, 6)]:
		var bot = botTemplate.instantiate()
		add_child(bot)
		bots.append(bot)
		
		if first:
			first = false
			tileSize = windowSize / tileCount
		
		bot.position = (pos + Vector2(0.5, 0.5)) * tileSize
		bot.scale *= tileSize.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
