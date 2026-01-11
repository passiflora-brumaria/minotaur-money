## User-defined category of income or expense instances.
class_name TransactionCategory extends Resource

## Name of the category.
@export var name: String

## Icon representing the category, per Font Awesome icon names.
@export var _icon_name: String

## Transactions belonging to this category.
@export var transactions: Array

## Reocurring transactions which will be applies onto this category.
@export var recurring_transactions: Array

func get_icon () -> String:
	return _icon_name

func set_icon (icon_name: String) -> Error:
	if get_available_icons().find(icon_name) >= 0:
		_icon_name = icon_name
		return Error.OK
	else:
		return Error.FAILED

## Gets a list of available category icons.
static func get_available_icons () -> Array[String]:
	return [
		"ankh","apple-whole","archway","baby-carriage","bacterium","bag-shopping","bed",
		"brain","dice-d20","city","euro-sign","hand-fist","hand-holding-heart","hat-wizard",
		"paw","people-group","poop","pump-soap","transgender","tree"
	]
