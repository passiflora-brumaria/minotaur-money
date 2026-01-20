extends MarginContainer

## Previous screen in navigation, to which the app should go back after editing is done.
@export var _previous_screen: Control

## Category to which the transaction will/does belong.
@export var _category: TransactionCategory

## Transaction to edit. Null for new creations, a reference to an existing transaction for editions.
@export var _transaction: Transaction

## Colour to associate to the category to which the transaction will/does belong.
@export var _category_colour: Color

## Sets the data for this screen.
func set_data (previous_screen: Control, category: TransactionCategory, transaction: Transaction, category_colour: Color) -> void:
	_previous_screen = previous_screen
	_category = category
	_transaction = transaction
	_category_colour = category_colour

@onready var _category_icon: FontAwesome = $"./Stack/TitleRow/CategoryIcon"
@onready var _category_name: Label = $"./Stack/TitleRow/CategoryName"
@onready var _integer_value_field: LineEdit = $"./Stack/ValueEdit/Integer"
@onready var _decimal_value_field: LineEdit = $"./Stack/ValueEdit/Decimal"
@onready var _name_field: LineEdit = $"./Stack/NameEdit"
@onready var _date_day_field: OptionButton = $"./Stack/DateEdit/DaySelect"
@onready var _date_month_field: OptionButton = $"./Stack/DateEdit/MonthSelect"
@onready var _date_year_field: LineEdit = $"./Stack/DateEdit/YearField"
@onready var _submit_button: Button = $"./Stack/Submit"

var _editable_model: Transaction

func _on_value_text_changed (_v: String) -> void:
	_editable_model.value = Decimal.parse(_integer_value_field.text + "," + _decimal_value_field.text,",")

func _on_name_text_changed (new_name: String) -> void:
	_editable_model.name = new_name

func _on_date_day_changed (idx: int) -> void:
	var day: int = _date_day_field.get_item_id(idx)
	var day_offset: int = day - _editable_model.date.day
	_editable_model.date.add_days(day_offset)
	_populate_date_field_options()

func _on_date_month_changed (idx: int) -> void:
	var month: int = _date_month_field.get_item_id(idx)
	var month_offset: int = month - _editable_model.date.month
	_editable_model.date.add_months(month_offset)
	_populate_date_field_options()

func _on_date_year_changed (value: String) -> void:
	var year = int(value)
	var year_offset: int = year - _editable_model.date.year
	_editable_model.date.add_months(year_offset * 12)
	_populate_date_field_options()

func _populate_date_field_options () -> void:
	_date_day_field.clear()
	for day_idx in range(Date.get_last_day_of_month(_editable_model.date.year,_editable_model.date.month)):
		_date_day_field.add_item(str(day_idx + 1),day_idx + 1)
	_date_day_field.selected = _date_day_field.get_item_index(_editable_model.date.day)
	_date_month_field.clear()
	for month_idx in range(12):
		var month_name: String = tr("MONTH_" + str(month_idx + 1).pad_zeros(2))
		if len(month_name) > 4:
			month_name = month_name.substr(0,3) + "."
		_date_month_field.add_item(month_name,month_idx + 1)
	_date_month_field.selected = _date_month_field.get_item_index(_editable_model.date.month)
	_date_year_field.text = str(_editable_model.date.year)

func _on_submit_pressed () -> void:
	if len(_category.transactions) == 0:
		_category.transactions.push_back(_editable_model)
	else:
		if _transaction != null:
			var original_idx: int = _category.transactions.find(_transaction)
			_category.transactions.remove_at(original_idx)
		var insertion_idx: int = 0
		while (insertion_idx < len(_category.transactions)) && _category.transactions.get(insertion_idx).date.is_prior_to(_editable_model.date):
			insertion_idx += 1
		_category.transactions.insert(insertion_idx,_editable_model)
	AppData.notify_changes()
	Navigation.request_page(_previous_screen,null)

func _ready () -> void:
	if _transaction != null:
		_editable_model = _transaction.copy()
	else:
		_editable_model = Transaction.new()
	_category_icon.icon_name = _category.get_icon()
	_category_icon.add_theme_color_override("font_color",_category_colour)
	_category_name.text = _category.name
	_category_name.add_theme_color_override("font_color",_category_colour)
	if _editable_model.value == null:
		_editable_model.value = Decimal.construct(0,[],false)
	_integer_value_field.text = str(_editable_model.value.get_integer_part())
	_decimal_value_field.text = _editable_model.value.get_decimal_part()
	_integer_value_field.text_changed.connect(_on_value_text_changed)
	_decimal_value_field.text_changed.connect(_on_value_text_changed)
	_name_field.text = _editable_model.name
	_name_field.text_changed.connect(_on_name_text_changed)
	if _editable_model.date == null:
		_editable_model.date = Date.now()
	_populate_date_field_options()
	_date_day_field.item_selected.connect(_on_date_day_changed)
	_date_month_field.item_selected.connect(_on_date_month_changed)
	_date_year_field.text_changed.connect(_on_date_year_changed)
	_submit_button.pressed.connect(_on_submit_pressed)
