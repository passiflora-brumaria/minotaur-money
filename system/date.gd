## Calendar date.
class_name Date extends Resource

## Year of this date.
@export var year: int

## Month of this date. It must be between 1 and 12.
@export var month: int

## Day of this date. It must be between 1 and 31.
@export var day: int

## Writes onto this date from a dictionary, like the one returned by [method Time.get_date_dict_from_system].
func from_dictionary (source: Dictionary) -> void:
	if source.has("year"):
		year = source.get("year")
	if source.has("month"):
		month = source.get("month")
	if source.has("day"):
		day = source.get("day")

## Parses a date from a dictionary, like the one returned by [method Time.get_date_dict_from_system].
static func parse_dict (source: Dictionary) -> Date:
	var newd: Date = Date.new()
	newd.from_dictionary(source)
	return newd

## Writes onto this date from an ISO 8601 date string.
func from_iso_string (source: String) -> void:
	if (source.length() >= 10) && (source.substr(4,1) == "-") && (source.substr(7,1) == "-"):
		year = int(source.substr(0,4))
		month = int(source.substr(5,2))
		day = int(source.substr(8,2))

## Parses a date from an ISO 8601 date string.
static func parse_iso (source: String) -> Date:
	var newd: Date = Date.new()
	newd.from_iso_string(source)
	return newd

## Writes onto this date from the current OS date.
func from_current (utc: bool = false) -> void:
	from_dictionary(Time.get_date_dict_from_system(utc))

## Gets the current date.
static func now (utc: bool = false) -> Date:
	var newd: Date = Date.new()
	newd.from_current(utc)
	return newd

## Reads from this date onto an ISO 8601 date string.
func to_iso_string () -> String:
	return str(year).pad_zeros(4) + "-" + str(month).pad_zeros(2) + "-" + str(day).pad_zeros(2)

## Gets the last day of a given month.
static func get_last_day_of_month (query_year: int, query_month: int) -> int:
	if [1,3,5,7,8,10,12].find(query_month) >= 0:
		return 31
	elif [4,6,9,11].find(query_month) >= 0:
		return 30
	elif (query_year % 4) == 0:
		return 29
	else:
		return 28

## Adds one day to this day.
func add_day () -> void:
	day += 1
	if day > get_last_day_of_month(year,month):
		day = 1
		month += 1
		if month > 12:
			month = 1
			year += 1

## Sets this date back by one day.
func remove_day () -> void:
	day -= 1
	if day <= 0:
		month -= 1
		if month <= 0:
			year -= 1
			month = 12
		day = get_last_day_of_month(year,month)

## Adds a positive number of days to this date. The number can be negative.
func add_days (n_days: int) -> void:
	if n_days > 0:
		for i in range(abs(n_days)):
			add_day()
	else:
		for i in range(abs(n_days)):
			remove_day()

## Adds a month to the current date.
func add_month () -> void:
	month += 1
	if month > 12:
		month = 1
		year += 1
	if day > get_last_day_of_month(year,month):
		day = get_last_day_of_month(year,month)

## Adds a number of months to this date. The number van be negative.
func add_months (n_months: int) -> void:
	month += n_months
	if month > 12:
		year += (month - 1) / 12
		month = ((month - 1) % 12) + 1
	else:
		while month < 1:
			year -= 1
			month += 12
	if day > get_last_day_of_month(year,month):
		day = get_last_day_of_month(year,month)

## Gets whether this date is prior to another.
func is_prior_to (other: Date, or_equal: bool = false) -> bool:
	if year == other.year:
		if month == other.month:
			if day == other.day:
				return or_equal
			else:
				return day < other.day
		else:
			return month < other.month
	else:
		return year < other.year

## Gets whether this is the same date as another.
func equals (other: Date) -> bool:
	return (year == other.year) && (month == other.month) && (day == other.day)

## Gets a copy of this date.
func copy () -> Date:
	return duplicate_deep(DEEP_DUPLICATE_ALL)
