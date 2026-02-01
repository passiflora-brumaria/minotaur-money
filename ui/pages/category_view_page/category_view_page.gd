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
@onready var _graph_panel: PanelContainer = $"./Stack/HistoryGraph"
@onready var _graph_viewport: SubViewport = $"./Stack/HistoryGraph/GraphPanelPadding/GraphPanelStack/GraphContainer/GraphVp"
@onready var _view_button: Button = $"./Stack/SeeTransactions"
@onready var _edit_button: Button = $"./Stack/Edit"

func _get_month_histogram () -> Dictionary[String,Decimal]:
	var histogram: Dictionary[String,Decimal] = {}
	for t in _category.transactions:
		var t_month: Date = t.date.copy()
		t_month.day = Date.get_last_day_of_month(t_month.year,t_month.month)
		var key: String = t_month.to_iso_string()
		var value: Decimal = t.value.copy()
		if histogram.has(key):
			histogram[key] = Decimal.add([histogram[key],value])
		else:
			histogram[key] = value
	if histogram.size() > 2:
		var min_month: String = histogram.keys().min()
		var max_month: String = histogram.keys().max()
		var date_checker := Date.parse_iso(min_month)
		while date_checker.is_prior_to(Date.parse_iso(max_month)):
			if !histogram.has(date_checker.to_iso_string()):
				histogram[date_checker.to_iso_string()] = Decimal.zero()
			date_checker.add_month()
			date_checker.day = Date.get_last_day_of_month(date_checker.year,date_checker.month)
	elif histogram.size() == 1:
		var date_checker := Date.parse_iso(histogram.keys().get(0))
		if (date_checker.year == _date_of_visit.year) && (date_checker.month == _date_of_visit.month):
			date_checker.add_months(-1)
			date_checker.day = Date.get_last_day_of_month(date_checker.year,date_checker.month)
			histogram[date_checker.to_iso_string()] = Decimal.zero()
		else:
			date_checker = _date_of_visit.copy()
			date_checker.day = Date.get_last_day_of_month(date_checker.year,date_checker.month)
			histogram[date_checker.to_iso_string()] = Decimal.zero()
	elif histogram.size() == 0:
		var date_checker := _date_of_visit.copy()
		date_checker.add_days(-1)
		histogram[date_checker.to_iso_string()] = Decimal.zero()
		date_checker.add_day()
		histogram[date_checker.to_iso_string()] = Decimal.zero()
	return histogram

func _on_transaction_history_requested () -> void: # TODO. To transaction history.
	pass

func _on_category_edit_requested () -> void: # TODO. To category edit.
	pass

func _ready () -> void:
	_category_icon.icon_name = _category.get_icon()
	_category_icon.add_theme_color_override("font_color",_category_colour)
	_category_name.text = _category.name
	_category_name.add_theme_color_override("font_color",_category_colour)
	var graph_panel_box: StyleBoxFlat = _graph_panel.get_theme_stylebox("panel")
	graph_panel_box.bg_color = _category_colour
	_graph_viewport.add_child(LineGraph.new(
		_get_month_histogram() as Dictionary,
		func (date_string: String): return tr("MONTH_" + str(Date.parse_iso(date_string).month).pad_zeros(2)) + " " + str(Date.parse_iso(date_string).year),
		func (value: Decimal): return value.to_string(),
		func (x0: String, x1: String): return x0 < x1,
		func (y: Decimal, histogram: Dictionary): return (y.to_float() / Decimal.maximum(histogram.values()).to_float()),
		_graph_viewport.size
	))
	_view_button.pressed.connect(_on_transaction_history_requested)
	_edit_button.pressed.connect(_on_category_edit_requested)

# TODO. Screen where user can select whether to see category transaction history or to edit the transaction.

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		var previous_screen := _previous_screen_scene.instantiate()
		previous_screen.set_data(_previous_screen_data)
		Navigation.request_page(previous_screen,null)
		queue_free()
