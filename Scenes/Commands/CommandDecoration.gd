extends Container
class_name CommandDecoration

@onready var _pid_marker := $HBoxContainer/PidMarker
@onready var _command_root := $HBoxContainer/CommandRoot

@onready var _delete_overlay1 := $DeleteOverlay1
@onready var _delete_overlay2 := $DeleteOverlay2

var command:
	get: 
		return command
	set(new_command):
		if command != new_command:
			command = new_command
			
			if _command_root.get_child_count() > 0:
				_command_root.remove_child(_command_root.get_child(0))
			
			_command_root.add_child(command)
			
var is_current: bool:
	get:
		return is_current
	set(new_is_current):
		is_current = new_is_current
		_pid_marker.modulate = Color.WHITE if is_current else Color.TRANSPARENT

var is_about_to_delete: bool:
	get:
		return is_about_to_delete
	set(new_is_about_to_delete):
		if is_about_to_delete != new_is_about_to_delete:
			is_about_to_delete = new_is_about_to_delete
			_delete_overlay1.visible = is_about_to_delete
			_delete_overlay2.visible = is_about_to_delete

var _program_list: BoxContainer
var _dragging := false
var _drag_start_position: Vector2
func _on_grip_marker_gui_input(event: InputEvent) -> void:
	const x_offset_for_delete := -100
	
	if event is InputEventMouseButton:
		if not _dragging and event.button_index == 1 and event.pressed:
			# start drag
			_dragging = true
			_drag_start_position = get_global_mouse_position() - global_position
			
			if not _program_list:
				_program_list = get_parent()
			
			accept_event()
		elif _dragging and event.button_index == 1 and not event.pressed:
			# end drag
			_dragging = false
			
			# delete?
			if position.x < x_offset_for_delete:
				_program_list.remove_child(self)
				GlobalScene.commands.remove_at(GlobalScene.commands.find(command))
			
			# position back in place
			set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		# dragging
		global_position = get_global_mouse_position() - _drag_start_position
		
		# figure out where to reposition in the list
		var target_program_entry: Control
		var target_program_entry_index := -1
		for program_entry in _program_list.get_children():
			target_program_entry_index += 1
			if program_entry is CommandDecoration:
				if program_entry.global_position.y > global_position.y:
					break
				else:
					target_program_entry = program_entry
		
		# moved?
		target_program_entry_index = max(1, target_program_entry_index)
		var my_command_index = GlobalScene.commands.find(command)
		if target_program_entry_index > my_command_index:
			target_program_entry_index -= 1
		if GlobalScene.commands[-1].global_position.y + GlobalScene.commands[-1].size.y <= global_position.y:
			target_program_entry_index += 1
			
		if target_program_entry != self:
			_program_list.move_child(self, target_program_entry_index)
			
			GlobalScene.commands.remove_at(my_command_index)
			GlobalScene.commands.insert(target_program_entry_index - 1, command)
		
		is_about_to_delete = position.x < x_offset_for_delete
		
		accept_event()

func _on_resized() -> void:
	if _delete_overlay1 and _delete_overlay2:
		_delete_overlay1.points[1] = size
	
		_delete_overlay2.points[0].y = size.y
		_delete_overlay2.points[1].x = size.x
