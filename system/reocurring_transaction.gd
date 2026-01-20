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

## First ocurrence of this transaction which hasn't been instantiated in the timeline yet.
@export var next_application: Date

func _move_application () -> void:
	match timescale:
		Timeframe.WEEK:
			next_application.add_days(7)
		Timeframe.MONTH:
			next_application.add_month()
		Timeframe.YEAR:
			next_application.add_months(12)

## Creates the next apprearences up to a certain date of this transaction. This will move the needle of application of this reocurrence (see [ReocurringCategory.next_application]).
func create_appearences (up_to: Date) -> Array[Transaction]:
	var appearences: Array[Transaction] = []
	while next_application.is_prior_to(up_to,true):
		var instance: Transaction = blueprint.copy()
		instance.date = next_application
		appearences.push_back(instance)
		_move_application()
	return appearences
