extends ScrollContainer

## Account to summarise on this page.
@export var _account: Account

## Date of visit.
@export var _date_of_viewing: Date

@onready var _account_select: Button = $"./Stack/AccountSelectPadding/AccountSelection"
@onready var _balance: Label = $"./Stack/CurrentBalancePadding/CurrentBalance"
@onready var _month: Label = $"./Stack/MonthSummaryMargin/MonthSummary/MonthSummaryPadding/MonthSummaryStack/CurrentMonth"

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

func _exit_tree () -> void:
	_account_select.pressed.disconnect(_on_account_select)
