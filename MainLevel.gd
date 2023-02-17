extends Node2D

var botTemplate = preload("res://Bot.tscn")
var tiles = []

func _ready():
	var item = botTemplate.instantiate()
	item.position = Vector2(100, 100)
	item.show()
	add_child(item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
