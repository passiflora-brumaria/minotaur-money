extends MarginContainer

## Previous screen in navigation, to which the app should go back after editing is done.
@export var _previous_screen_scene: PackedScene

## Model(s) for the previous screen in navigation.
@export var _previous_screen_data: Dictionary

## Category to which the transaction will/does belong.
@export var _category: TransactionCategory

## Transaction to edit. Null for new creations, a reference to an existing transaction for editions.
@export var _transaction: Transaction

## Colour to associate to the category to which the transaction will/does belong.
@export var _category_colour: Color

## Sets the data for this screen. Expects:
## "previous_screen_scene": [class PackedScene]
## "previous_screen_data": [class.Dictionary]
## "category": [class TransactionCategory
## "transaction": [class Transaction]
## "category_colour": [class Color]
func set_data (data: Dictionary) -> void:
	if data.has("previous_screen_scene"):
		_previous_screen_scene = data["previous_screen_scene"]
	if data.has("previous_screen_data"):
		_previous_screen_data = data["previous_screen_data"]
	if data.has("category"):
		_category = data["category"]
	if data.has("transaction"):
		_transaction = data["transaction"]
	if data.has("category_colour"):
		_category_colour = data["category_colour"]

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
var _add_recurrence: bool
var _recurrence_type: ReocurringTransaction.Timeframe

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

func _on_recurrence_set (option_idx: int) -> void:
	var option_id: int = $"./Stack/RecurrenceEdit".get_item_id(option_idx)
	match option_id:
		0:
			_add_recurrence = false
		1:
			_add_recurrence = true
			_recurrence_type = ReocurringTransaction.Timeframe.WEEK
		2:
			_add_recurrence = true
			_recurrence_type = ReocurringTransaction.Timeframe.MONTH
		3:
			_add_recurrence = true
			_recurrence_type = ReocurringTransaction.Timeframe.YEAR
		_:
			_add_recurrence = false

func _on_submit_pressed () -> void:
	if len(_category.transactions) == 0:
		_category.transactions.push_back(_editable_model)
	else:
		if _transaction != null:
			var original_idx: int = _category.transactions.find(_transaction)
			_category.transactions.remove_at(original_idx)
		elif _add_recurrence:
			var r := ReocurringTransaction.new()
			r.blueprint = _editable_model.copy()
			r.origin = _editable_model.date.copy()
			r.next_application = _editable_model.date.copy()
			r.timescale = _recurrence_type
			var avoid_first_day := _editable_model.date.copy()
			avoid_first_day.add_day()
			r.create_appearences(avoid_first_day)
			_category.recurring_transactions.push_back(r)
		var insertion_idx: int = 0
		while (insertion_idx < len(_category.transactions)) && _category.transactions.get(insertion_idx).date.is_prior_to(_editable_model.date):
			insertion_idx += 1
		_category.transactions.insert(insertion_idx,_editable_model)
	AppData.notify_changes()
	var previous_screen := _previous_screen_scene.instantiate()
	previous_screen.set_data(_previous_screen_data)
	Navigation.request_page(previous_screen,null)
	queue_free()

func _ready () -> void:
	_add_recurrence = false
	if _transaction != null:
		_editable_model = _transaction.copy()
		$"./Stack/DateMargin".queue_free()
		$"./Stack/RecurrenceLabel".queue_free()
		$"./Stack/RecurrenceGap".queue_free()
		$"./Stack/RecurrenceEdit".queue_free()
	else:
		_editable_model = Transaction.new()
		$"./Stack/RecurrenceEdit".select($"./Stack/RecurrenceEdit".get_item_index(0))
		$"./Stack/RecurrenceEdit".item_selected.connect(_on_recurrence_set)
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

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		var previous_screen := _previous_screen_scene.instantiate()
		previous_screen.set_data(_previous_screen_data)
		Navigation.request_page(previous_screen,null)
		queue_free()
