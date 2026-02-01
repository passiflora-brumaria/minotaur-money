## 2D lune graph based on a histogram.
class_name LineGraph extends Node2D

## Set of data points in a {x: y} format.
@export var _histogram: Dictionary

## Converter of each x value to a displayable string. (x) => String.
@export var _x_string_getter: Callable

## Converter of each y value to a displayable string. (y) => String.
@export var _y_string_getter: Callable

## Getter for x value sorting, returning if the first parameter is lesser than the second. (x, x2) => bool.
@export var _x_sort: Callable

## Converter which gets for each y value a float between -1.0 and 1.0. (y, Dictionary) => float.
@export var _y_magnitude: Callable

## Size of the resulting diagram.
@export var _size: Vector2

## Create a new 2D graph based on a histogram and some getters/converters.[br]
## [param histogram]: Set of data points in a {x: y} format.[br]
## [param x_string_getter]: Converter of each x value to a displayable string. (x) => String.[br]
## [param y_string_getter]: Converter of each y value to a displayable string. (y) => String.[br]
## [param x_sort]: Getter for x value sorting, returning if the first parameter is lesser than the second. (x, x2) => bool.[br]
## [param y_magnitude]: Converter which gets for each y value a float between -1.0 and 1.0. (y, Dictionary) => float.[br]
## [param size]: Size of the resulting diagram.
func _init (histogram: Dictionary, x_string_getter: Callable, y_string_getter: Callable, x_sort: Callable, y_magnitude: Callable, size: Vector2) -> void:
	_histogram = histogram
	_x_string_getter = x_string_getter
	_y_string_getter = y_string_getter
	_x_sort = x_sort
	_y_magnitude = y_magnitude
	_size = size

func _ready () -> void: # TODO. Implement.
	var coming_soon: Label = Label.new()
	coming_soon.text = "GRAPH GOES HERE"
	add_child(coming_soon)
	if _histogram.size() < 2:
		push_error("Not enough data points to construct graph. Destroying graph attempt.")
		queue_free()
	var data_points_x: Array[String] = []
	var data_points_y: Array[float] = []
	var keys: Array = _histogram.keys()
	keys.sort_custom(_x_sort)
	for x in keys:
		print("Getting graph point: x = " + _x_string_getter.call(x) + "; y = " + _y_string_getter.call(_histogram[x]))
		data_points_x.append(_x_string_getter.call(x))
		data_points_y.append(_y_magnitude.call(_histogram[x],_histogram))
	print(data_points_x)
	print(data_points_y)
