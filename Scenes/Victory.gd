extends Control

@onready var _next_level_button := $CenterContainer/VBoxContainer/HBoxContainer/NextLevelButton

func _on_exit_button_pressed() -> void:
	get_tree().quit()

signal next_level_pressed
func _on_next_level_button_pressed() -> void:
	next_level_pressed.emit()

func _ready() -> void:
	GlobalScene.current_level_index_changed.connect(func():
		_next_level_button.disabled = GlobalScene.current_level_index >= len(GlobalScene.levels))
	$BlurSprite.scale = get_viewport_rect().size
