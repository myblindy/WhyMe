extends Control
class_name CommandBase

@export var bot: Bot

func _initialize_actions(name: String, addresses: bool, inbox: bool, outbox: bool, plus_minus: bool) -> void:
	$Name.text = name
	
	var addresses_menu_button := MenuButton.new()
	var addresses_menu_button_popup := addresses_menu_button.get_popup()
		
	var _add_item := func(text: String, action: Callable):
		var item_index := addresses_menu_button_popup.item_count
		
		addresses_menu_button_popup.add_item(text)
		addresses_menu_button_popup.index_pressed.connect(func(index: int):
				if index == item_index:
					addresses_menu_button.text = text
					action.call())
	
	# boxes
	if inbox:
		_add_item.call("inbox", func(): _select_item(true, false, -1, -1))
	if outbox:
		_add_item.call("outbox", func(): _select_item(false, true, -1, -1))
	
	# addresses
	if addresses:
		for address_index in len(GlobalScene.numeric_addresses):
			_add_item.call(str(address_index + 1), func(): _select_item(false, false, address_index, -1))
	
	# +/-
	if plus_minus:
		_add_item.call("+", func(): _select_item(false, false, -1, 0))
		_add_item.call("-", func(): _select_item(false, false, -1, 1))
	
	# select the default value
	if inbox or outbox or addresses or plus_minus:
		add_child(addresses_menu_button)
		addresses_menu_button_popup.index_pressed.emit(0)

var inbox_selected := false
var outbox_selected := false
var address_selected := -1
var plus_minus_selected := -1

func _select_item(inbox: bool, outbox: bool, address: int, plus_minus: int):
	if inbox:
		outbox = false
		address = -1
		plus_minus = -1
	elif outbox:
		inbox = false
		address = -1
		plus_minus = -1
	elif address >= 0:
		inbox = false
		outbox = false
		plus_minus = -1
	elif plus_minus >= 0:
		inbox = false
		outbox = false
		address = -1
		
	inbox_selected = inbox;
	outbox_selected = outbox
	address_selected = address
	plus_minus_selected = plus_minus

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

func _move_in_direction(move_type: GlobalTypes.MoveType) -> void:
	if move_type == GlobalTypes.MoveType.MOVE_N:
		await _move_to_position(bot.position + Vector2(0, -1))
	elif move_type == GlobalTypes.MoveType.MOVE_S:
		await _move_to_position(bot.position + Vector2(0, 1))
	elif move_type == GlobalTypes.MoveType.MOVE_E:
		await _move_to_position(bot.position + Vector2(1, 0))
	elif move_type == GlobalTypes.MoveType.MOVE_W:
		await _move_to_position(bot.position + Vector2(-1, 0))

func _move_to_position(target: Vector2) -> void:
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
			
func _move_to_address(index: int):
	await _move_to_position(GlobalScene.numeric_addresses[index])
	
func _move():
	if address_selected >= 0:
		await _move_to_address(address_selected)
	elif inbox_selected:
		await _move_to_position(GlobalScene.inbox.interact_position)
	elif outbox_selected:
		await _move_to_position(GlobalScene.outbox.interact_position)

# waits for the duration of a normal action 
func _action_wait():
	await get_tree().create_timer(1).timeout

func run() -> void:
	pass
	
func stop() -> void:
	pass
