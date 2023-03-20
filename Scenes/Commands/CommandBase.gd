extends Control
class_name CommandBase

@export var bot: Bot

func _play_move_animation(move_type: GlobalTypes.MoveType) -> void:
	match move_type:
		GlobalTypes.MoveType.MOVE_S:
			bot.play_animation("walk-down")
		GlobalTypes.MoveType.MOVE_N:
			bot.play_animation("walk-up")
		GlobalTypes.MoveType.MOVE_E:
			bot.play_animation("walk-right")
		GlobalTypes.MoveType.MOVE_W:
			bot.play_animation("walk-left")
		_:
			bot.play_animation("idle-blink")

func _move(move_type: GlobalTypes.MoveType) -> void:
	if move_type == GlobalTypes.MoveType.MOVE_N:
		await _move_to(bot.position + Vector2(0, -1))
	elif move_type == GlobalTypes.MoveType.MOVE_S:
		await _move_to(bot.position + Vector2(0, 1))
	elif move_type == GlobalTypes.MoveType.MOVE_E:
		await _move_to(bot.position + Vector2(1, 0))
	elif move_type == GlobalTypes.MoveType.MOVE_W:
		await _move_to(bot.position + Vector2(-1, 0))

func _move_to(target: Vector2) -> void:
	while true:
		var dv: Vector2
		var move_type := GlobalTypes.MoveType.NONE
		if bot.position.x > target.x:
			dv = Vector2(-1, 0)
			move_type = GlobalTypes.MoveType.MOVE_W
		elif bot.position.x < target.x:
			dv = Vector2(1, 0)
			move_type = GlobalTypes.MoveType.MOVE_E
		elif bot.position.y > target.y:
			dv = Vector2(0, -1)
			move_type = GlobalTypes.MoveType.MOVE_N
		elif bot.position.y < target.y:
			dv = Vector2(0, 1)
			move_type = GlobalTypes.MoveType.MOVE_S
		
		_play_move_animation(move_type)
		if dv != Vector2.ZERO:
			if bot.command_tween:
				bot.command_tween.kill()
				bot.command_tween = null
			bot.command_tween = bot.get_tree().create_tween()
			bot.command_tween.tween_property(bot, "position", bot.position + dv, 1.0)
			await bot.command_tween.finished
		else:
			break

# waits for the duration of a normal action 
func _action_wait():
	await get_tree().create_timer(1).timeout

func run() -> void:
	pass
	
func stop() -> void:
	pass
