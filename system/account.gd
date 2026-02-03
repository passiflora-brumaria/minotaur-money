## Account movements from/to which are being tracked.
class_name Account extends Resource

## Name of the account.
@export var name: String

## Starting balance of the account at time of creation in the app.
@export var starting_balance: Decimal = Decimal.zero()

## Transcaction categories which represent positive increments in money.
@export var income_categories: Array[TransactionCategory] = []

## Transaction categories which represent negative increments in money.
@export var expense_categories: Array[TransactionCategory] = []

## Gets the value of the income for this account between two dates, inclusive. Leave a limit date as null as to not limit the query on that end.
func get_income (query_beginning: Date, query_ending: Date) -> Decimal:
	var sum: Decimal = Decimal.construct(0,[],false)
	for ic in income_categories:
		sum = Decimal.add([sum,ic.get_value(query_beginning,query_ending)])
	return sum

## Gets the value of the accumulated expenses for this account between two dates, inclusive. Leave a limit date as null as to not limit the query on that end.
func get_expense (query_beginning: Date, query_ending: Date) -> Decimal:
	var sum: Decimal = Decimal.construct(0,[],false)
	for ec in expense_categories:
		sum = Decimal.add([sum,ec.get_value(query_beginning,query_ending)])
	return sum

## Returns the balance of this account.
func get_balance (as_of: Date) -> Decimal:
	var query = as_of.duplicate_deep(DEEP_DUPLICATE_ALL) if (as_of != null) else Date.now()
	var sum: Decimal = starting_balance.copy()
	for ic in income_categories:
		for t in ic.transactions:
			if t.date.is_prior_to(query,true):
				sum = Decimal.add([sum,t.value.get_absolute_value()])
	for ec in expense_categories:
		for t in ec.transactions:
			if t.date.is_prior_to(query,true):
				sum = Decimal.add([sum,t.value.get_absolute_value().opposite()])
	return sum
