extends MarginContainer

## Category being edited, or null if this page is being used to create a new category.
@export var _category: TransactionCategory
## Whether the category to edit/add represents income (or expenses, otherwise).
@export var _is_income: bool
## Page to which to go back after this page is done.
@export var _previous_page_scene: PackedScene
## Data to send to the previous page.
@export var _previous_page_data: Dictionary

func set_data (data: Dictionary) -> void:
	if data.has("category"):
		_category = data["category"]
	if data.has("is_income"):
		_is_income = data["is_income"]
	if data.has("previous_page_scene"):
		_previous_page_scene = data["previous_page_scene"]
	if data.has("previous_page_data"):
		_previous_page_data = data["previous_page_data"]

var _editable_model: TransactionCategory
var _is_income_editable: bool

func _on_name_changed (new_value: String) -> void:
	_editable_model.name = new_value

func _ready () -> void:
	if _category != null:
		_editable_model = _category.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		$"./Stack/TitleRow/PageIcon".icon_name = "pen"
		$"./Stack/TitleRow/AccountTitle".text = _editable_model.name
	else:
		_editable_model = TransactionCategory.new()
		$"./Stack/TitleRow/PageIcon".icon_name = "circle-plus"
		$"./Stack/TitleRow/AccountTitle".text = tr("ADD_NEW_CATEGORY")
		_editable_model.set_icon(TransactionCategory.get_available_icons().get(0))
	_is_income_editable = _is_income
	$"./Stack/TitleRow/PageIcon".add_theme_color_override("font_color",Color.from_string("#CCD5AE",Color.ALICE_BLUE) if _is_income_editable else Color.from_string("#D4A373",Color.ALICE_BLUE))
	$"./Stack/TitleRow/AccountTitle".add_theme_color_override("font_color",Color.from_string("#CCD5AE",Color.ALICE_BLUE) if _is_income_editable else Color.from_string("#D4A373",Color.ALICE_BLUE))
	$"./Stack/NameEdit".text_changed.connect(_on_name_changed) ## TODO. Icon and income/expese fields.

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		var previous_screen := _previous_page_scene.instantiate()
		previous_screen.set_data(_previous_page_data)
		Navigation.request_page(previous_screen,null)
		queue_free()
