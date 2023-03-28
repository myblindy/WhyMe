extends Node2D
class_name InOutBox 

const _scale := Vector2(1.0 / 64.0, 1.0 / 64.0)
const _conveyor_texture := preload("res://Assets/World/conveyor_belt.png")
const _conveyor_material := preload("res://Assets/World/conveyor_belt_animated_shader_material.tres")

class QueuedObjectType:
	var object: WorldObject
	# 1 means promote to previous cell
	var offset: float
	var frozen: bool

var _is_input: bool
var _conveyor_sprites: Array[Sprite2D] = []
var _object_queue: Array[QueuedObjectType] = []

var _interact_position: Vector2
var interact_position: Vector2:
	get:
		return _interact_position
		
signal _interaction_available
func wait_for_interaction_available() -> void:
	if _is_input and len(_object_queue) > 0 and _object_queue[0].object:
		return
	if not _is_input and (len(_object_queue) == 0 or not _object_queue[0].object):
		return
	await _interaction_available

func setup(cell_count: int, input: bool) -> void:
	for cell_index in cell_count:
		var conveyor_sprite := Sprite2D.new()
		add_child(conveyor_sprite)
		_conveyor_sprites.append(conveyor_sprite)
		
		# enqueue an empty slot
		_object_queue.append(QueuedObjectType.new())
		
		conveyor_sprite.texture = _conveyor_texture
		conveyor_sprite.material = _conveyor_material
		conveyor_sprite.scale = _scale
		conveyor_sprite.position = Vector2(0, cell_index)
		
		if not input:
			conveyor_sprite.rotation_degrees = 180
		
	_interact_position = position + Vector2(1 if input else -1, 0)
	_is_input = input

signal object_enqueued
func enqueue_object(value: String) -> void:
	var new_object := QueuedObjectType.new()
	var new_world_object: WorldObject = GlobalScene._world_object_scene.instantiate()
	new_world_object.value = value
	new_world_object.scale = _scale * 0.8
	add_child(new_world_object)
	new_object.object = new_world_object

	if _is_input:
		# make sure we start off-screen
		while(len(_object_queue) < len(_conveyor_sprites)):
			_object_queue.append(QueuedObjectType.new())
			
		new_world_object.position = Vector2(0, len(_object_queue))
		_object_queue.append(new_object)
	else:
		# here we start on top of the conveyor
		new_world_object.position = Vector2(0, 0)
		new_object.offset = 0
		if len(_object_queue) == 0:
			_object_queue.append(QueuedObjectType.new())
		_object_queue[0] = new_object
		
		# unfreeze everything to make room for more
		for object in _object_queue:
			object.frozen = false
			
		# notify observers that we have a new item
		object_enqueued.emit()

func dequeue_object() -> String:
	if len(_object_queue) > 0 and _object_queue[0].object:
		remove_child(_object_queue[0].object)
		var value := _object_queue[0].object.value
		_object_queue[0].object = null
		for object in _object_queue:
			object.frozen = false
		return value
	return ""

func clear_objects() -> void:
	for object in _object_queue:
		if object.object:
			remove_child(object.object)
	_object_queue.clear()
	
func get_objects() -> Array[String]:
	var result: Array[String] = []
	
	for object in _object_queue:
		if object.object and object.object.value != "":
			result.append(object.object.value)
	result.reverse()
	return result

func _process_input(delta: float) -> void:
	for object_queue_index in len(_object_queue):
		var object := _object_queue[object_queue_index]
		if object_queue_index > 0 and object.object:
			var previous_object := _object_queue[object_queue_index - 1]
			if not previous_object.frozen:
				object.offset += delta
				object.object.position -= Vector2(0, delta)
				
				# promotion
				if object.offset >= 1.0:
					previous_object.object = object.object
					previous_object.offset = object.offset - 1.0
					
					# this cell is now empty
					if object_queue_index == len(_object_queue) - 1:
						_object_queue.remove_at(object_queue_index)
					else:
						object.object = null
					
					# chain freeze
					if (object_queue_index >= 2 and _object_queue[object_queue_index - 2].frozen) or object_queue_index == 1:
						previous_object.frozen = true
						previous_object.offset = 0
						previous_object.object.position.y = object_queue_index - 1
						
					if object_queue_index:
						_interaction_available.emit()

func _process_output(delta: float) -> void:
	for object_queue_index in range(len(_object_queue) - 1, -1, -1):
		var object := _object_queue[object_queue_index]
		if object.object and not object.frozen:
			object.offset += delta
			object.object.position += Vector2(0, delta)
			
			if object.offset >= 1:
				# move up and freeze
				if object_queue_index == len(_object_queue) - 1:
					_object_queue.append(QueuedObjectType.new())
				_object_queue[object_queue_index + 1].frozen = true
				_object_queue[object_queue_index + 1].object = object.object
				_object_queue[object_queue_index + 1].object.position.y = object_queue_index + 1
				_object_queue[object_queue_index + 1].offset = object.offset - 1
				object.object = null
				object.offset = 0
				
				if object_queue_index == 0:
					_interaction_available.emit()
					
func _process(delta: float) -> void:
	if _is_input:
		_process_input(delta)
	else:
		_process_output(delta)
