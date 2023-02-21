extends Node

enum TILE_TYPE
{
	NONE, TILE0, TILE1
}

enum MOVE_TYPE
{
	MOVE_N, MOVE_E, MOVE_S, MOVE_W
}

var known_commands := [
	CommandMove,
	CommandPickup
]

var commands := []

func _ready():
	pass 
