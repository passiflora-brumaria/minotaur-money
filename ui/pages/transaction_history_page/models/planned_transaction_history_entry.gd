## Entry based on a planned transaction.
class_name PlannedTransactionHistoryEntry extends TransactionHistoryEntry

@export var planned_transaction: ReocurringTransaction

@export var planned_date: Date

## Creates an entry based on a planned transaction.
func _init (pt: ReocurringTransaction, d: Date, c: TransactionCategory, clr: Color) -> void:
	planned_transaction = pt
	planned_date = d
	category = c
	colour = clr

func get_description () -> String:
	return planned_transaction.blueprint.name

func get_date () -> Date:
	return planned_date

func get_value () -> Decimal:
	return planned_transaction.blueprint.value

func is_actual () -> bool:
	return false
