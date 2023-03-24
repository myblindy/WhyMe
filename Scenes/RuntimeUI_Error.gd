extends RichTextLabel

func _ready() -> void:
	GlobalScene.error_changed.connect(func():
		var text := ""
		var error := GlobalScene.get_error()
		
		if error.message != "":
			text += "[color=red]Error: " + error.message + "[/color]\n"
			
			if error.expected_value != null:
				text += "Expected: [color=green]" + error.expected_value + "[/color]\n"
				
			if error.provided_value != null:
				text += "Provided: [color=red]" + error.provided_value + "[/color]\n"
		
		self.text = text)
