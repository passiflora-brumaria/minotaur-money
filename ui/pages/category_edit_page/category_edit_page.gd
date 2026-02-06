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

@onready var _home_page_scene = load("res://ui/pages/home_page/home_page.tscn")

var _editable_model: TransactionCategory
var _is_income_editable: bool

func _on_name_changed (new_value: String) -> void:
	_editable_model.name = new_value
	if _category != null:
		$"./Stack/TitleRow/AccountTitle".text = _editable_model.name

func _on_type_changed (item_index: int) -> void:
	_is_income_editable = ($"./Stack/TypeEdit".get_item_id(item_index)) == 1
	$"./Stack/TitleRow/PageIcon".add_theme_color_override("font_color",Color.from_string("#CCD5AE",Color.ALICE_BLUE) if _is_income_editable else Color.from_string("#D4A373",Color.ALICE_BLUE))
	$"./Stack/TitleRow/AccountTitle".add_theme_color_override("font_color",Color.from_string("#CCD5AE",Color.ALICE_BLUE) if _is_income_editable else Color.from_string("#D4A373",Color.ALICE_BLUE))

func _on_icon_changed (selected_button: BaseButton) -> void:
	if selected_button is IconSelectButton:
		_editable_model.set_icon((selected_button as IconSelectButton).get_icon_name())

func _on_submitted () -> void:
	var account: Account = AppData.data.accounts.get(0)
	if _category != null:
		var is_found: bool = false
		var account_idx: int = 0
		while (!is_found) && (account_idx < len(AppData.data.accounts)):
			var acc: Account = AppData.data.accounts.get(account_idx)
			var category_index: int = -1
			if _is_income:
				category_index = acc.income_categories.find(_category)
				if category_index >= 0:
					acc.income_categories.remove_at(category_index)
			else:
				category_index = acc.expense_categories.find(_category)
				if category_index >= 0:
					acc.expense_categories.remove_at(category_index)
			is_found = category_index >= 0
			if is_found:
				account = acc
	if _is_income_editable:
		account.income_categories.push_back(_editable_model)
	else:
		account.expense_categories.push_back(_editable_model)
	Navigation.request_page(_home_page_scene.instantiate(),null)
	queue_free()

func _ready () -> void:
	if _category != null:
		_editable_model = _category.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		$"./Stack/TitleRow/PageIcon".icon_name = "pen"
		$"./Stack/TitleRow/AccountTitle".text = _editable_model.name
	else:
		_editable_model = TransactionCategory.new()
		_editable_model.name = ""
		$"./Stack/TitleRow/PageIcon".icon_name = "circle-plus"
		$"./Stack/TitleRow/AccountTitle".text = tr("ADD_NEW_CATEGORY")
		_editable_model.set_icon(TransactionCategory.get_available_icons().get(0))
	_is_income_editable = _is_income
	$"./Stack/TitleRow/PageIcon".add_theme_color_override("font_color",Color.from_string("#CCD5AE",Color.ALICE_BLUE) if _is_income_editable else Color.from_string("#D4A373",Color.ALICE_BLUE))
	$"./Stack/TitleRow/AccountTitle".add_theme_color_override("font_color",Color.from_string("#CCD5AE",Color.ALICE_BLUE) if _is_income_editable else Color.from_string("#D4A373",Color.ALICE_BLUE))
	$"./Stack/NameEdit".text = _editable_model.name
	$"./Stack/NameEdit".text_changed.connect(_on_name_changed) ## TODO. Icon field.
	$"./Stack/TypeEdit".select($"./Stack/TypeEdit".get_item_index(int(_is_income_editable)))
	$"./Stack/TypeEdit".item_selected.connect(_on_type_changed)
	var icon_select_group := ButtonGroup.new()
	for icon in TransactionCategory.get_available_icons():
		var icon_button := IconSelectButton.new(icon,_editable_model.get_icon(),icon_select_group)
		$"./Stack/IconGrid".add_child(icon_button)
	icon_select_group.pressed.connect(_on_icon_changed)
	$"./Stack/Submit".pressed.connect(_on_submitted)

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		var previous_screen := _previous_page_scene.instantiate()
		previous_screen.set_data(_previous_page_data)
		Navigation.request_page(previous_screen,null)
		queue_free()
