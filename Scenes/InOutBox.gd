extends Node2D
class_name InOutBox

var _conveyor_sprites: Array[Sprite2D] = []
var _object_queue: Array[String] = []

func setup(cell_count: int, input: bool):
	var conveyor_texture: Texture2D = preload("res://Assets/World/conveyor_belt.png")
	
	for cell_index in cell_count:
		var conveyor_sprite := Sprite2D.new()
		add_child(conveyor_sprite)
		_conveyor_sprites.append(conveyor_sprite)
		
		conveyor_sprite.texture = conveyor_texture
		conveyor_sprite.scale = Vector2(1.0 / 64.0, 1.0 / 64.0)
		conveyor_sprite.position = Vector2(0, cell_index)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
