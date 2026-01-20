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

var _current_touch: InputEventScreenTouch = null
var _current_touch_length: float = 0.0

## Sets the model data for this scene.
func set_data (category: TransactionCategory, beginning_date: Date, ending_date: Date, category_colour: Color, background_colour: Color) -> void:
	_category = category
	_beginning_date = beginning_date
	_ending_date = ending_date
	_category_colour = category_colour
	_background_colour = background_colour

## Signal fired when this category display has been tapped.
signal pressed ()
## Signal fired when this category display has been long-pressed.
signal long_pressed ()

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

func _process (delta: float) -> void:
	if _current_touch != null:
		if _current_touch_length > 1.0:
			pressed.emit()
			_current_touch = null
		else:
			_current_touch_length += delta

func _input (ev: InputEvent) -> void:
	if ev is InputEventScreenTouch:
		var stev: InputEventScreenTouch = ev
		if get_global_rect().encloses(Rect2(stev.position,Vector2.ONE)):
			if stev.double_tap:
				long_pressed.emit()
			else:
				_current_touch = stev
				_current_touch_length = 0.0
