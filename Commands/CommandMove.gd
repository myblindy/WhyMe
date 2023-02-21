extends Command
class_name CommandMove

const name := "Move"
const scene := preload("res://Scenes/Commands/CommandMoveScene.tscn")

var move_type = GlobalScene.MOVE_TYPE.MOVE_N

func _init() -> void:
	pass
