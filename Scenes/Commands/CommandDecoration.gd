extends HBoxContainer
class_name CommandDecoration

@onready var _pid_marker := $PidMarker
@onready var _command_root := $CommandRoot

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

var _program_list: BoxContainer
var _dragging := false
var _drag_start_position: Vector2
func _on_grip_marker_gui_input(event: InputEvent) -> void:
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
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		# dragging
		global_position = get_global_mouse_position() - _drag_start_position
		
		# figure out where to reposition in the list
		var current_program_entry: Control
		var current_program_entry_index := -1
		for program_entry in _program_list.get_children():
			if program_entry is CommandDecoration:
				if program_entry.global_position.y > global_position.y:
					break
				else:
					current_program_entry = program_entry
			current_program_entry_index += 1
		
		# moved?
		if current_program_entry != self:
			_program_list.move_child(self, current_program_entry_index)
		
		accept_event()
