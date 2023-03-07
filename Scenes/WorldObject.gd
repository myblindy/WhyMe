extends Node2D
class_name WorldObject

@onready var _label := $Label

var value: String:
	get:
		return value;
	set(new_value):
		if _label:
			_label.text = new_value	
		value = new_value

func _ready():
	scale = Vector2(1, 1) / _label.size
	_label.text = value
