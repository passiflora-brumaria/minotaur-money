extends MarginContainer

## Category being represented.
@export var _category: TransactionCategory

## Beginning date of query for the value of the category.
@export var _beginning_date: Date

## Ending date of query for the value of the category.
@export var _ending_date: Date

## Colour representing the category.
@export var _category_colour: Color

## Background colour of where the category will be displayed.
@export var _background_colour: Color

## Sets the model data for this scene.
func set_data (category: TransactionCategory, beginning_date: Date, ending_date: Date, category_colour: Color, background_colour: Color) -> void:
	_category = category
	_beginning_date = beginning_date
	_ending_date = ending_date
	_category_colour = category_colour
	_background_colour = background_colour

@onready var _title: Label = $"./CategoryStack/CategoryTitle"
@onready var _panel: PanelContainer = $"./CategoryStack/IconPanelCenterer/CategoryIconPanel"
@onready var _icon: FontAwesome = $"./CategoryStack/IconPanelCenterer/CategoryIconPanel/CategoryIconCenterer/FontAwesome"
@onready var _value: Label = $"./CategoryStack/Value"

func _ready () -> void:
	_title.text = _category.name
	_panel.add_theme_stylebox_override("panel",_panel.get_theme_stylebox("panel").duplicate_deep(Resource.DEEP_DUPLICATE_ALL))
	_panel.get_theme_stylebox("panel").set("bg_color",_category_colour)
	_icon.icon_name = _category.get_icon()
	_icon.add_theme_color_override("font_color",_background_colour)
	_value.text = _category.get_value(_beginning_date,_ending_date).to_string() + " €"
	_value.add_theme_color_override("font_color",_category_colour)
