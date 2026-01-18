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

## Gets whether this date is prior to another.
func is_prior_to (other: Date, or_equal: bool = false) -> bool:
	if year == other.year:
		if month == other.year:
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
