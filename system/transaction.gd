## Increment in money being registered.
class_name Transaction extends Resource

## Monetary value of the transaction. Must be 0 or greater.
@export var value: Decimal

## Name given by the user to the transaction.
@export var name: String

## Date at which the transaction occurred.
@export var date: Date

## Gets a copy of this transaction.
func copy () -> Transaction:
	return duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
