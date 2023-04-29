extends Control

@onready var button_group: ButtonGroup = get_child(0).button_group


func _ready():
	for i in get_children().size():
		button_group.get_buttons()[i].toggled.connect(_on_toggled.bind(i))


func _on_toggled(_pressed, index):
	Global.current_tool = index
