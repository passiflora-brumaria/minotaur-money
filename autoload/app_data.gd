extends Node

## Signal emitted when changes are made to the app's data. It fires a reference to the data.
signal data_changed (data_ref: UserData)

## User data.
var data: UserData

func _load_defaults () -> void:
	var groceries := TransactionCategory.new()
	groceries.name = tr("DATADEFAULTS_CATEGORY_GROCERIES")
	groceries.set_icon("apple-whole")
	var transportation := TransactionCategory.new()
	transportation.name = tr("DATADEFAULTS_CATEGORY_TRANSPORTATION")
	transportation.set_icon("train-subway")
	var charity := TransactionCategory.new()
	charity.name = tr("DATADEFAULTS_CATEGORY_CHARITY")
	charity.set_icon("hand-fist")
	var gaming := TransactionCategory.new()
	gaming.name = tr("DATADEFAULTS_CATEGORY_GAMING")
	gaming.set_icon("dice-d20")
	var other_expenses := TransactionCategory.new()
	other_expenses.name = tr("DATADEFAULTS_CATEGORY_OTHEREXPENSES")
	other_expenses.set_icon("bag-shopping")
	var salary := TransactionCategory.new()
	salary.name = tr("DATADEFAULTS_CATEGORY_SALARY")
	salary.set_icon("city")
	var gifts := TransactionCategory.new()
	gifts.name = tr("DATADEFAULTS_CATEGORY_GIFTS")
	gifts.set_icon("people-group")
	var personal_account := Account.new()
	personal_account.name = tr("DATADEFAULTS_ACCOUNT_PERSONAL")
	personal_account.expense_categories = [groceries,transportation,charity,gaming,other_expenses]
	personal_account.income_categories =  [salary,gifts]
	data.accounts = [personal_account]

func _ready () -> void:
	if ResourceLoader.exists("user://data.tres"):
		data = ResourceLoader.load("user://data.tres")
	else:
		data = UserData.new()
		#_load_defaults()
		ResourceSaver.save(data,"user://data.tres")
	var current_day: Date = Date.now()
	for acc in data.accounts:
		for ic in acc.income_categories:
			for rec in ic.recurring_transactions:
				var applications: Array[Transaction] = rec.create_appearences(current_day)
				ic.transactions.append_array(applications)
			ic.transactions.sort_custom( func (a: Transaction, b: Transaction): return a.date.is_prior_to(b.date) )
		for ec in acc.expense_categories:
			for rec in ec.recurring_transactions:
				var applications: Array[Transaction] = rec.create_appearences(current_day)
				ec.transactions.append_array(applications)
			ec.transactions.sort_custom( func (a: Transaction, b: Transaction): return a.date.is_prior_to(b.date) )
	await get_tree().process_frame
	if len(data.accounts) == 0:
		var create_first_account: Control = load("res://ui/pages/account_edit_page/account_edit_page.tscn").instantiate()
		create_first_account.set_data({
			"account": null,
			"previous_page_scene": null
		})
		Navigation.request_page(create_first_account,null)
	else:
		Navigation.request_page(load("res://ui/pages/home_page/home_page.tscn").instantiate(),null)

## Notify all subscriptors that changes have been made to the data.
func notify_changes () -> void:
	data_changed.emit(data)
	ResourceSaver.save(data,"user://data.tres")
