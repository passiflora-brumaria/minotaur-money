## Transaction which repeats itself.
class_name ReocurringTransaction extends Resource

enum Timeframe { ## Amount of time which may pass between instances of a reocurring transaction.
	WEEK, ## The transaction occurs every 7 days.
	MONTH, ## The transaction occurs every 1 month.
	YEAR ## The transaction occurs every 12 months.
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

## Creates the next apprearences up to a certain date of this transaction. This will move the needle of application of this reocurrence (see [member ReocurringCategory.next_application]).
func create_appearences (up_to: Date) -> Array[Transaction]:
	if (ending != null) && ending.is_prior_to(next_application):
		return []
	var appearences: Array[Transaction] = []
	while next_application.is_prior_to(up_to,true):
		var instance: Transaction = blueprint.copy()
		instance.date = next_application
		if (ending == null) || instance.date.is_prior_to(ending,true):
			appearences.push_back(instance)
		_move_application()
	return appearences

## Gets the future applications of this reocurring transaction without moving the needle of application (see [member ReocurringCategory.next_application]).
func foresee_future_appearences (up_to: Date) -> Array[Transaction]:
	if (ending != null) && ending.is_prior_to(next_application):
		return []
	var appearences: Array[Transaction] = []
	var future_application: Date = next_application.copy()
	while future_application.is_prior_to(up_to,true):
		var instance: Transaction = blueprint.copy()
		instance.date = future_application
		if (ending == null) || instance.date.is_prior_to(ending,true):
			appearences.push_back(instance)
		match timescale:
			Timeframe.WEEK:
				future_application.add_days(7)
			Timeframe.MONTH:
				future_application.add_month()
			Timeframe.YEAR:
				future_application.add_months(12)
	return appearences
