extends ScrollContainer

## Account to summarise on this page.
@export var _account: Account

## Date of visit.
@export var _date_of_viewing: Date

## Sets the data to display on this page. Expects:
## "account": [class Account]
## "date_of_viewing": [class Date]
func set_data (data: Dictionary) -> void:
	if data.has("account"):
		_account = data["account"]
	if data.has("date_of_viewing"):
		_date_of_viewing = data["date_of_viewing"]

@onready var _category_view_scene: PackedScene = preload("res://ui/pages/home_page/components/category_display/category_display.tscn")
@onready var _self_scene: PackedScene = preload("res://ui/pages/home_page/home_page.tscn")
@onready var _transaction_edit_page_scene: PackedScene = preload("res://ui/pages/transaction_edit_page/transaction_edit_page.tscn")
@onready var _category_view_page_scene: PackedScene = preload("res://ui/pages/category_view_page/category_view_page.tscn")
@onready var _account_select_page_scene: PackedScene = preload("res://ui/pages/account_selection_page/account_selection_page.tscn")

@onready var _account_select: Button = $"./Stack/AccountSelectPadding/AccountSelection"
@onready var _balance: Label = $"./Stack/CurrentBalancePadding/CurrentBalance"
@onready var _month: Label = $"./Stack/MonthSummaryMargin/MonthSummary/MonthSummaryPadding/MonthSummaryStack/CurrentMonth"
@onready var _monthly_income: Label = $"./Stack/MonthSummaryMargin/MonthSummary/MonthSummaryPadding/MonthSummaryStack/MonthBalance/MonthIcome/MonthIncomePadding/Row/Column/Amount"
@onready var _monthly_expense: Label = $"./Stack/MonthSummaryMargin/MonthSummary/MonthSummaryPadding/MonthSummaryStack/MonthBalance/MonthExpenses/MonthIncomePadding/Row/Column/Amount"
@onready var _category_grid: GridContainer = $"./Stack/MonthSummaryMargin/MonthSummary/MonthSummaryPadding/MonthSummaryStack/CategoryGrid"

var _swipe_gestures: Dictionary[int,Vector2]

func _on_account_select () -> void:
	var account_select_page := _account_select_page_scene.instantiate()
	Navigation.request_page(account_select_page,null) ## TODO. Addition FAB?
	queue_free()

func _on_category_tapped (category: TransactionCategory, colour: Color) -> void:
	var transaction_page := _transaction_edit_page_scene.instantiate()
	transaction_page.set_data({
		"previous_screen_scene": _self_scene,
		"previous_screen_data": {
			"account": _account,
			"date_of_viewing": _date_of_viewing
		},
		"category": category,
		"transaction": null,
		"category_colour": colour
	})
	Navigation.request_page(transaction_page,null)
	queue_free()

func _on_category_long_pressed (category: TransactionCategory, is_income: bool, colour: Color) -> void:
	var category_page := _category_view_page_scene.instantiate()
	category_page.set_data({
		"previous_screen_scene": _self_scene,
		"previous_screen_data": {
			"account": _account,
			"date_of_viewing": _date_of_viewing
		},
		"category": category,
		"is_category_income": is_income,
		"category_colour": colour,
		"date_of_visit": _date_of_viewing
	})
	Navigation.request_page(category_page,null)
	queue_free()

func _on_previous_month () -> void:
	_date_of_viewing.add_months(-1)
	_on_app_data_changed(AppData.data)

func _on_next_month () -> void:
	_date_of_viewing.add_month()
	_on_app_data_changed(AppData.data)

func _on_app_data_changed (_data_ref) -> void:
	_account_select.text = _account.name
	_balance.text = _account.get_balance(Date.now()).to_string() + " €"
	_month.text = tr("MONTH_" + str(_date_of_viewing.month).pad_zeros(2)) + ", " + str(_date_of_viewing.year)
	var query_b: Date = _date_of_viewing.copy()
	query_b.day = 1
	var query_e: Date = _date_of_viewing.copy()
	query_e.day = Date.get_last_day_of_month(query_e.year,query_e.month)
	_monthly_income.text = _account.get_income(query_b,query_e).to_string() + " €"
	_monthly_expense.text = _account.get_expense(query_b,query_e).to_string() + " €"
	while _category_grid.get_child_count() > 0:
		var c := _category_grid.get_child(0)
		_category_grid.remove_child(c)
		c.queue_free()
	for ic in _account.income_categories:
		var cdisplay := _category_view_scene.instantiate()
		cdisplay.set_data(ic,query_b,query_e,Color.from_string("#CCD5AE",Color.ALICE_BLUE),Color.from_string("#fefefe",Color.RED))
		cdisplay.pressed.connect(_on_category_tapped.bind(ic,Color.from_string("#CCD5AE",Color.ALICE_BLUE)))
		cdisplay.long_pressed.connect(_on_category_long_pressed.bind(ic,true,Color.from_string("#CCD5AE",Color.ALICE_BLUE)))
		_category_grid.add_child(cdisplay)
	for ec in _account.expense_categories:
		var cdisplay := _category_view_scene.instantiate()
		cdisplay.set_data(ec,query_b,query_e,Color.from_string("#D4A373",Color.ALICE_BLUE),Color.from_string("#fefefe",Color.RED))
		cdisplay.pressed.connect(_on_category_tapped.bind(ec,Color.from_string("#D4A373",Color.ALICE_BLUE)))
		cdisplay.long_pressed.connect(_on_category_long_pressed.bind(ec,false,Color.from_string("#D4A373",Color.ALICE_BLUE)))
		_category_grid.add_child(cdisplay)

func _ready () -> void:
	if _account != null:
		AppData.data.accounts.push_front(_account)
		var idx: int = 1
		while idx < len(AppData.data.accounts):
			if AppData.data.accounts.get(idx) == _account:
				AppData.data.accounts.remove_at(idx)
			else:
				idx += 1
		AppData.notify_changes()
	else:
		_account = AppData.data.accounts.get(0)
	if _date_of_viewing == null:
		_date_of_viewing = Date.now()
	_swipe_gestures = {}
	_account_select.pressed.connect(_on_account_select)
	_on_app_data_changed(AppData.data)
	AppData.data_changed.connect(_on_app_data_changed)

func _exit_tree () -> void:
	_account_select.pressed.disconnect(_on_account_select)
	AppData.data_changed.disconnect(_on_app_data_changed)

func _input (ev: InputEvent) -> void:
	if ev is InputEventScreenDrag:
		var sdev: InputEventScreenDrag = ev
		if sdev.screen_velocity.length() > 50.0:
			_swipe_gestures.set(sdev.index,sdev.screen_velocity.normalized())
	if ev is InputEventScreenTouch:
		var stev: InputEventScreenTouch = ev
		if _swipe_gestures.has(stev.index) && !stev.pressed:
			var swipe_direction: Vector2 = _swipe_gestures.get(stev.index,Vector2.ZERO)
			_swipe_gestures.erase(stev.index)
			if swipe_direction.x > 0.3:
				_on_previous_month()
			elif swipe_direction.x < 0.3:
				_on_next_month()

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		get_tree().quit()
