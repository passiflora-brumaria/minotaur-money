## User-defined category of income or expense instances.
class_name TransactionCategory extends Resource

## Name of the category.
@export var name: String

## Icon representing the category, per Font Awesome icon names.
@export var _icon_name: String

## Transactions belonging to this category.
@export var transactions: Array[Transaction] = []

## Reocurring transactions which will be applied onto this category.
@export var recurring_transactions: Array[ReocurringTransaction] = []

func get_icon () -> String:
	return _icon_name

func set_icon (icon_name: String) -> Error:
	if get_available_icons().find(icon_name) >= 0:
		_icon_name = icon_name
		return Error.OK
	else:
		return Error.FAILED

## Gets the value accrued on this category between two points in time, inclusive. Leave a query limit null to not limit the checked timespan in its end.
func get_value (query_beginning: Date, query_ending: Date) -> Decimal:
	var sum: Decimal = Decimal.construct(0,[],false)
	for t in transactions:
		if (query_beginning == null) || query_beginning.is_prior_to(t.date,true):
			if (query_ending == null) || t.date.is_prior_to(query_ending,true):
				sum = Decimal.add([sum,t.value.get_absolute_value()])
	return sum

## Gets a list of available category icons.
static func get_available_icons () -> Array[String]:
	return [
		"ankh","apple-whole","archway","baby-carriage","bacterium","bag-shopping","bed",
		"brain","dice-d20","city","euro-sign","hand-fist","hand-holding-heart","hat-wizard",
		"paw","people-group","pump-soap","transgender","train-subway","tree"
	]
