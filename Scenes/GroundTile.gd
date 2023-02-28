extends Node2D

@onready var _numeric_address_label := $NumericAddress
@onready var _sprite := $Sprite2D

@export var tile_kind := GlobalScene.TILE_TYPE.NONE:
	get:
		return tile_kind
	set(new_tile_kind):
		match new_tile_kind:
			GlobalScene.TILE_TYPE.TILE0:
				_sprite.modulate = Color(0, 0.8, 0, 1)
				_numeric_address_label.modulate = Color.BLACK
			GlobalScene.TILE_TYPE.TILE1:
				_numeric_address_label.modulate = Color.WHITE
				_sprite.modulate = Color(0, 0.4, 0, 1)
			_:
				_numeric_address_label.modulate = Color.WHITE
				_sprite.modulate = Color(0, 0, 0, 1)
		
		tile_kind = new_tile_kind

@export var numeric_address: int:
	get:
		return numeric_address
	set(new_numeric_address):
		if new_numeric_address >= 0:
			_numeric_address_label.show()
			_numeric_address_label.text = str(new_numeric_address + 1)
		else:
			_numeric_address_label.hide()
		
		numeric_address = new_numeric_address

func _ready():
	scale = Vector2.ONE / _numeric_address_label.size
