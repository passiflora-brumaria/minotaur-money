extends MarginContainer

## Page to which to go back on back button.
@export var _previous_screen_scene: PackedScene

## Model(s) for the previous page.
@export var _previous_screen_data: Dictionary

## Category being viewed.
@export var _category: TransactionCategory

## Colour associated with this category.
@export var _category_colour: Color

## Date of visit, on which to base graphs and history reports.
@export var _date_of_visit: Date

## Sets te data necessary for view generation. Expects:
## "previous_screen_scene": [class PackedScene]
## "previous_screen_data": [class Dictionary]
## "category": [class TransactionCategory]
## "category_colour": [class Color]
## "date_of_visit": [class Date]
func set_data (data: Dictionary) -> void:
	if data.has("previous_screen_scene"):
		_previous_screen_scene = data["previous_screen_scene"]
	if data.has("previous_screen_data"):
		_previous_screen_data = data["previous_screen_data"]
	if data.has("category"):
		_category = data["category"]
	if data.has("category_colour"):
		_category_colour = data["category_colour"]
	if data.has("date_of_visit"):
		_date_of_visit = data["date_of_visit"]

@onready var _category_icon: FontAwesome = $"./Stack/TitleRow/CategoryIcon"
@onready var _category_name: Label = $"./Stack/TitleRow/CategoryName"

func _ready () -> void:
	_category_icon.icon_name = _category.get_icon()
	_category_icon.add_theme_color_override("font_color",_category_colour)
	_category_name.text = _category.name
	_category_name.add_theme_color_override("font_color",_category_colour)

# TODO. Screen where user can select whether to see category transaction history or to edit the transaction.

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		var previous_screen := _previous_screen_scene.instantiate()
		previous_screen.set_data(_previous_screen_data)
		Navigation.request_page(previous_screen,null)
		queue_free()
