extends Node2D

@export var tile_kind = GlobalScene.TILE_TYPE.NONE:
	get:
		return tile_kind
	set(new_tile_kind):
		match new_tile_kind:
			GlobalScene.TILE_TYPE.TILE0:
				$Sprite2D.modulate = Color(0, 0.8, 0, 1)
			GlobalScene.TILE_TYPE.TILE1:
				$Sprite2D.modulate = Color(0, 0.4, 0, 1)
			_:
				$Sprite2D.modulate = Color(0, 0, 0, 1)
		
		tile_kind = new_tile_kind

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
