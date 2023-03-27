extends CommandBase
class_name CommandLabel

var label_name: String

func _ready() -> void:
	var params := InitializeParameters.new("Label")
	params.create_label = true
	_initialize_actions(params)
