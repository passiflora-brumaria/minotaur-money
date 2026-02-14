extends MarginContainer

@export var _model: ReocurringTransaction

@export var _previous_page_scene: PackedScene

@export var _previous_page_data: Dictionary

func set_data (data: Dictionary) -> void:
	if data.has("model"):
		_model = data["model"]
	if data.has("previous_page_scene"):
		_previous_page_scene = data["previous_page_scene"]
	if data.has("previous_page_data"):
		_previous_page_data = data["previous_page_data"]

var _infinite: bool
var _ending_date: Date

func _on_infinity_toggled () -> void:
	_infinite = !_infinite
	$"./Stack/DateEdit/DaySelect".disabled = _infinite
	$"./Stack/DateEdit/MonthSelect".disabled = _infinite
	$"./Stack/DateEdit/YearField".editable = !_infinite

func _on_date_selected () -> void:
	_ending_date.year = int($"./Stack/DateEdit/YearField".text)
	_ending_date.month = $"./Stack/DateEdit/MonthSelect".get_item_id($"./Stack/DateEdit/MonthSelect".selected)
	_ending_date.day = $"./Stack/DateEdit/DaySelect".get_item_id($"./Stack/DateEdit/DaySelect".selected)
	if _ending_date.day > Date.get_last_day_of_month(_ending_date.year,_ending_date.month):
		_ending_date.day = Date.get_last_day_of_month(_ending_date.year,_ending_date.month)
	$"./Stack/DateEdit/DaySelect".clear()
	for day_idx in range(Date.get_last_day_of_month(_ending_date.year,_ending_date.month)):
		$"./Stack/DateEdit/DaySelect".add_item(str(day_idx + 1),day_idx + 1)
	$"./Stack/DateEdit/DaySelect".select($"./Stack/DateEdit/DaySelect".get_item_index(_ending_date.day))

func _on_submitted () -> void:
	_model.ending = null if _infinite else _ending_date
	AppData.notify_changes()
	var previous_screen := _previous_page_scene.instantiate()
	previous_screen.set_data(_previous_page_data)
	Navigation.request_page(previous_screen,null)
	queue_free()

func _ready () -> void:
	if _model.ending == null:
		_infinite = true
		_ending_date = Date.now()
	else:
		_infinite = false
		_ending_date = _model.ending.copy()
	$"./Stack/TitleRow/Title".text = _model.blueprint.name
	$"./Stack/Value".text = _model.blueprint.value.to_string() + " €"
	$"./Stack/From".text = str(_model.origin.day)
	var month := tr("MONTH_" + str(_model.origin.month).pad_zeros(2))
	if len(month) > 4:
		month = month.substr(0,3) + "."
	$"./Stack/From".text += month + ", " + str(_model.origin.year)
	$"./Stack/Inifinite".button_pressed = _infinite
	$"./Stack/Inifinite".pressed.connect(_on_infinity_toggled)
	$"./Stack/DateEdit/YearField".text = str(_ending_date.year)
	$"./Stack/DateEdit/MonthSelect".clear()
	for month_idx in range(12):
		$"./Stack/DateEdit/MonthSelect".add_item(tr("MONTH_" + str(month_idx + 1).pad_zeros(2)),month_idx + 1)
	$"./Stack/DateEdit/MonthSelect".select($"./Stack/DateEdit/MonthSelect".get_item_index(_ending_date.month))
	$"./Stack/DateEdit/DaySelect".clear()
	for day_idx in range(Date.get_last_day_of_month(_ending_date.year,_ending_date.month)):
		$"./Stack/DateEdit/DaySelect".add_item(str(day_idx + 1),day_idx + 1)
	$"./Stack/DateEdit/DaySelect".select($"./Stack/DateEdit/DaySelect".get_item_index(_ending_date.day))
	$"./Stack/DateEdit/YearField".text_changed.connect(_on_date_selected)
	$"./Stack/DateEdit/MonthSelect".item_selected.connect(_on_date_selected)
	$"./Stack/DateEdit/DaySelect".item_selected.connect(_on_date_selected)
	$"./Stack/Submit".pressed.connect(_on_submitted)
	_on_infinity_toggled()
	_on_infinity_toggled()

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		var previous_screen := _previous_page_scene.instantiate()
		previous_screen.set_data(_previous_page_data)
		Navigation.request_page(previous_screen,null)
		queue_free()
