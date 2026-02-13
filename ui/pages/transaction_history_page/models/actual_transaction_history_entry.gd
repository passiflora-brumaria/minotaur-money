## Entry based on an actual transaction.
class_name ActualTransactionHistoryEntry extends TransactionHistoryEntry

@export var transaction: Transaction

## Creates an entry based on an actual transaction.
func _init (t: Transaction, c: TransactionCategory, clr: Color) -> void:
	transaction = t
	category = c
	colour = clr

func get_description () -> String:
	return transaction.name

func get_date () -> Date:
	return transaction.date

func get_value () -> Decimal:
	return transaction.value

func is_actual () -> bool:
	return true
