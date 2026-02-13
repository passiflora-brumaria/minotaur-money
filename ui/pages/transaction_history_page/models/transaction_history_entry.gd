## Data point to represent in a transaction history.
@abstract
class_name TransactionHistoryEntry extends Resource

@export var category: TransactionCategory

@export var colour: Color

## Gets the title (category name) for this transaction.
func get_title () -> String:
	return category.name

## Gets the text for this transaction.
@abstract
func get_description () -> String

## Gets the colour with which to represent this transaction.
func get_colour () -> Color:
	return colour

## Gets the date this entry occupies on the timeline.
@abstract
func get_date () -> Date

## Gets the monetary value of this transaction.
@abstract
func get_value () -> Decimal

## Gets whether this entry represents an actual transaction (as opposed to a planned one).
@abstract
func is_actual () -> bool
