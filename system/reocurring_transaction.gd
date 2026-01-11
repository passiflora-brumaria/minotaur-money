## Transaction which repeats itself.
class_name ReocurringTransaction extends Resource

enum Timeframe {
	WEEK,
	MONTH,
	YEAR
}

## Transaction to repeat.
@export var blueprint: Transaction

## Amount of time between instances of the transaction.
@export var timescale: Timeframe

## First occurrence of the transaction in this series.
@export var origin: Date

## Date of ending of the reocurrence. Null if it's to go forever.
@export var ending: Date
