extends MarginContainer

## The title of this page.
@export var _title: String

## The transactions represented in the page.
@export var _model: Array[TransactionHistoryEntry]

## Date to use as reference to get data in the case of an empty model.
@export var _date_of_viewing: Date

## Page to which to go back when the back button is pressed.
@export var _previous_page_scene: PackedScene

## Data to send to the previous page.
@export var _previous_page_data: Dictionary

## Sets the data for this view. Expects the following data: [br]
## "title": [class String] the title of this page. [br]
## "model": [class Array[TransactionHistoryEntry]] the transactions represented in the page.
## "date_of_viewing": [class Date] date to use as reference to get data in the case of an empty model.
## "previous_page_scene": [class PackedScene] page to which to go back when the back button is pressed.
## "previous_page_data": [class Dictionary] data to send to the previous page.
func set_data (data: Dictionary) -> void:
	if data.has("title"):
		_title = data["title"]
	if data.has("model"):
		_model = data["model"]
	if data.has("date_of_viewing"):
		_date_of_viewing = data["date_of_viewing"]
	if data.has("previous_page_scene"):
		_previous_page_scene = data["previous_page_scene"]
	if data.has("previous_page_data"):
		_previous_page_data = data["previous_page_data"]

var _sorted_model: Array[TransactionHistoryEntry]
var _transaction_edit_scene: PackedScene = preload("res://ui/pages/transaction_edit_page/transaction_edit_page.tscn")
var _self_scene: PackedScene = preload("res://ui/pages/transaction_history_page/transaction_history_page.tscn")
var _title_font: Font = preload("res://themes/normal_bold.ttf")
var _entry_view_scene: PackedScene = preload("res://ui/pages/transaction_history_page/components/transaction_history_entry_view/transaction_history_entry_view.tscn")

func _on_edit (t: TransactionHistoryEntry) -> void:
	if t.is_actual():
		var page := _transaction_edit_scene.instantiate()
		page.set_data({
			"previous_screen_scene": _self_scene,
			"previous_screen_data": {
				"title": _title,
				"model": _model,
				"date_of_viewing": _date_of_viewing,
				"previous_page_scene": _previous_page_scene,
				"previous_page_data": _previous_page_data
			},
			"category": t.category,
			"transaction": (t as ActualTransactionHistoryEntry).transaction,
			"category_colour": t.get_colour()
		})
		Navigation.request_page(page,null)
		queue_free()

func _build_view () -> void:
	var previous_date: Date = null
	for m in _sorted_model:
		if (previous_date == null) || !m.get_date().equals(previous_date):
			var date_margin := MarginContainer.new()
			date_margin.add_theme_constant_override("margin_bottom",40)
			$"./Stack".add_child(date_margin)
			var date_title := Label.new()
			date_title.text = m.get_date().to_iso_string()
			date_title.add_theme_constant_override("font_size",48)
			date_title.add_theme_font_override("font",_title_font)
			$"./Stack".add_child(date_title)
		var entry_view := _entry_view_scene.instantiate()
		entry_view.set_data(m)
		entry_view.edit_requested.connect(_on_edit)
		$"./Stack".add_child(entry_view)

func _ready () -> void:
	if len(_title) > 0:
		$"./Stack/TitleRow/AccountTitle".text = _title
	if (_model == null) || (len(_model) == 0):
		_model = []
		var begin_query := Date.now() if _date_of_viewing == null else _date_of_viewing.copy()
		begin_query.day = 1
		var end_query := Date.now() if _date_of_viewing == null else _date_of_viewing.copy()
		end_query.day = Date.get_last_day_of_month(end_query.year,end_query.month)
		var a: Account = AppData.data.accounts.get(0)
		for ic in a.income_categories:
			var color := Color.from_string("#CCD5AE",Color.ALICE_BLUE)
			for t in ic.transactions:
				if begin_query.is_prior_to(t.date,true) && t.date.is_prior_to(end_query,true):
					_model.push_back(ActualTransactionHistoryEntry.new(t,ic,color))
			for rt in ic.recurring_transactions:
				var planned_transactions := rt.foresee_future_appearences(end_query)
				for pt in planned_transactions:
					if begin_query.is_prior_to(pt.date,true):
						_model.push_back(PlannedTransactionHistoryEntry.new(rt,pt.date,ic,color))
		for ec in a.expense_categories:
			var color := Color.from_string("#D4A373",Color.ALICE_BLUE)
			for t in ec.transactions:
				if begin_query.is_prior_to(t.date,true) && t.date.is_prior_to(end_query,true):
					_model.push_back(ActualTransactionHistoryEntry.new(t,ec,color))
			for rt in ec.recurring_transactions:
				var planned_transactions := rt.foresee_future_appearences(end_query)
				for pt in planned_transactions:
					if begin_query.is_prior_to(pt.date,true):
						_model.push_back(PlannedTransactionHistoryEntry.new(rt,pt.date,ec,color))
	_sorted_model = []
	for m in _model:
		var search_index: int = 0
		var inserted: bool = 0
		while (!inserted) && (search_index < len(_sorted_model)):
			if _sorted_model.get(search_index).get_date().is_prior_to(m.get_date()):
				search_index += 1
			else:
				_sorted_model.insert(search_index,m)
				inserted = true
		if !inserted:
			_sorted_model.push_back(m)
	_build_view()

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		var previous_screen := _previous_page_scene.instantiate()
		previous_screen.set_data(_previous_page_data)
		Navigation.request_page(previous_screen,null)
		queue_free()
