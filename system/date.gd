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

## Writes onto this date from an ISO 8601 date string.
func from_iso_string (source: String) -> void:
	if (source.length() >= 10) && (source.substr(4,1) == "-") && (source.substr(7,1) == "-"):
		year = int(source.substr(0,4))
		month = int(source.substr(5,2))
		day = int(source.substr(8,2))

## Writes onto this date from the current OS date.
func from_current (utc: bool = false) -> void:
	from_dictionary(Time.get_date_dict_from_system(utc))

## Reads from this date onto an ISO 8601 date string.
func to_iso_string () -> String:
	return str(year).pad_zeros(4) + "-" + str(month).pad_zeros(2) + "-" + str(day).pad_zeros(2)
