extends Control
class_name CommandBase

@export var bot: Bot

class InitializeParameters:
	var name: String
	var addresses: bool
	var inbox: bool
	var outbox: bool
	var plus_minus: bool
	var create_label: bool
	var use_labels: bool
	var has_jump_types: bool
	
	func _init(name: String) -> void:
		self.name = name

func _initialize_actions(params: InitializeParameters) -> void:
	$Name.text = params.name
	
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
	if params.inbox:
		_add_item.call("inbox", func(): _select_item(true, false, -1, -1))
	if params.outbox:
		_add_item.call("outbox", func(): _select_item(false, true, -1, -1))
	
	# addresses
	if params.addresses:
		for address_index in len(GlobalScene.numeric_addresses):
			_add_item.call(str(address_index + 1), func(): _select_item(false, false, address_index, -1))
	
	# +/-
	if params.plus_minus:
		_add_item.call("+", func(): _select_item(false, false, -1, 0))
		_add_item.call("-", func(): _select_item(false, false, -1, 1))
	
	# select the default value
	if params.inbox or params.outbox or params.addresses or params.plus_minus:
		add_child(addresses_menu_button)
		addresses_menu_button_popup.index_pressed.emit(0)
		
	# create label
	if params.create_label:
		var edit := LineEdit.new()
		add_child(edit)
		edit.text_changed.connect(func(new_text): 
			print("text_changed: " + new_text)
			(self as CommandLabel).label_name = new_text)
		
		# generate new label name
		var i := 1
		var new_label_name: String
		while true:
			new_label_name = "L" + str(i)
			var exists := false
			for cmd in GlobalScene.commands:
				if cmd is CommandLabel and cmd.label_name == new_label_name:
					exists = true
					break
			
			if not exists:
				break
			i += 1
		edit.text = new_label_name
		edit.text_changed.emit(new_label_name)	# doesn't get called otherwise?

	# jump types
	if params.has_jump_types:
		var menu := MenuButton.new()
		add_child(menu)
		
		var menu_popup := menu.get_popup()
		var add_menu_popup := func(text: String, action: Callable):
			var item_index := menu_popup.item_count
			menu_popup.add_item(text)
			menu_popup.index_pressed.connect(func(index: int):
				if(index == item_index):
					menu.text = text
					action.call())
		add_menu_popup.call("ANY", func(): jump_type = GlobalTypes.JumpType.ALL)
		add_menu_popup.call("-", func(): jump_type = GlobalTypes.JumpType.NEGATIVE_VALUE)
		menu_popup.index_pressed.emit(0)
		
	if params.use_labels:
		var menu := MenuButton.new()
		add_child(menu)
		var menu_popup := menu.get_popup()
		
		# event dispatcher
		var handlers := {}
		menu_popup.index_pressed.connect(func(index: int):
			var handler = handlers[index]
			if handler:
				handler.call())
		
		menu.about_to_popup.connect(func():
			# clear and fill the dropdown with a list of all current labels
			menu_popup.clear()
			handlers.clear()
			
			for command in GlobalScene.commands:
				if command is CommandLabel:
					var index := menu_popup.item_count
					menu_popup.add_item(command.label_name)
					handlers[index] = func():
						menu.text = command.label_name
						jump_to_label_name = command.label_name
			)
		menu.show_popup()

var inbox_selected := false
var outbox_selected := false
var address_selected := -1
var plus_minus_selected := -1

var jump_to_label_name: String
var jump_type: GlobalTypes.JumpType

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
