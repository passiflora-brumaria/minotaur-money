extends ScrollContainer

## Account to summarise on this page.
@export var _account: Account

## Date of visit.
@export var _date_of_viewing: Date

## Sets the data to display on this page.
func set_data (account: Account, date_of_viewing: Date) -> void:
	_account = account
	_date_of_viewing = date_of_viewing

@onready var _category_view_scene: PackedScene = preload("res://ui/components/category_display/category_display.tscn")

@onready var _account_select: Button = $"./Stack/AccountSelectPadding/AccountSelection"
@onready var _balance: Label = $"./Stack/CurrentBalancePadding/CurrentBalance"
@onready var _month: Label = $"./Stack/MonthSummaryMargin/MonthSummary/MonthSummaryPadding/MonthSummaryStack/CurrentMonth"
@onready var _monthly_income: Label = $"./Stack/MonthSummaryMargin/MonthSummary/MonthSummaryPadding/MonthSummaryStack/MonthBalance/MonthIcome/MonthIncomePadding/Row/Column/Amount"
@onready var _monthly_expense: Label = $"./Stack/MonthSummaryMargin/MonthSummary/MonthSummaryPadding/MonthSummaryStack/MonthBalance/MonthExpenses/MonthIncomePadding/Row/Column/Amount"
@onready var _category_grid: GridContainer = $"./Stack/MonthSummaryMargin/MonthSummary/MonthSummaryPadding/MonthSummaryStack/CategoryGrid"

func _on_account_select () -> void:
	pass # TODO. Implement.

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
	_account_select.pressed.connect(_on_account_select)
	_account_select.text = _account.name
	_balance.text = _account.get_balance(Date.now()).to_string() + " €"
	_month.text = tr("MONTH_" + str(_date_of_viewing.month).pad_zeros(2))
	if len(_month.text) > 5:
		_month.text = _month.text.substr(0,3) + "."
	_month.text += ", " + str(_date_of_viewing.year)
	var query_b: Date = _date_of_viewing.copy()
	query_b.day = 1
	var query_e: Date = _date_of_viewing.copy()
	query_e.day = Date.get_last_day_of_month(query_e.year,query_e.month)
	_monthly_income.text = _account.get_income(query_b,query_e).to_string() + " €"
	_monthly_expense.text = _account.get_expense(query_b,query_e).to_string() + " €"
	for ic in _account.income_categories:
		var cdisplay := _category_view_scene.instantiate()
		cdisplay.set_data(ic,query_b,query_e,Color.from_string("#CCD5AE",Color.ALICE_BLUE),Color.from_string("#fefefe",Color.RED))
		_category_grid.add_child(cdisplay)
	for ec in _account.expense_categories:
		var cdisplay := _category_view_scene.instantiate()
		cdisplay.set_data(ec,query_b,query_e,Color.from_string("#D4A373",Color.ALICE_BLUE),Color.from_string("#fefefe",Color.RED))
		_category_grid.add_child(cdisplay)

func _exit_tree () -> void:
	_account_select.pressed.disconnect(_on_account_select)
