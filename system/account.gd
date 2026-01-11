## Account movements from/to which are being tracked.
class_name Account extends Resource

## Name of the account.
@export var name: String

## Transcaction categories which represent positive increments in money.
@export var income_categories: Array[TransactionCategory]

## Transaction categories which represent negative increments in money.
@export var expense_categories: Array[TransactionCategory]
