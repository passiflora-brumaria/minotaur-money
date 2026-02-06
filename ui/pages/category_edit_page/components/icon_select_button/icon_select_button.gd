## Button with which to assign an icon to a category.
class_name IconSelectButton extends CheckBox

var _icon_name: String
var _icon_texture: Texture
var _selected: bool
var _group: ButtonGroup

func _init (icon_name: String, selected_icon_name: String, icon_selection_group: ButtonGroup) -> void:
	_icon_name = icon_name
	_icon_texture = load("res://icons/" + _icon_name + "-solid.svg")
	_selected = _icon_name == selected_icon_name
	_group = icon_selection_group

func _ready () -> void:
	button_group = _group
	custom_minimum_size = 100.0 * Vector2.ONE
	icon = _icon_texture
	expand_icon = true
	text = ""
	if _selected:
		button_pressed = true

## Gets the name of the icon selected through this button.
func get_icon_name () -> String:
	return _icon_name
