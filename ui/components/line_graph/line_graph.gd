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

## Create a new 2D graph based on a histogram and some getters/converters.
## [param histogram]: Set of data points in a {x: y} format.
## [param x_string_getter]: Converter of each x value to a displayable string. (x) => String.
## [param y_string_getter]: Converter of each y value to a displayable string. (y) => String.
## [param x_sort]: Getter for x value sorting, returning if the first parameter is lesser than the second. (x, x2) => bool.
## [param y_magnitude]: Converter which gets for each y value a float between -1.0 and 1.0. (y, Dictionary) => float.
## [param size]: Size of the resulting diagram.
func _init (histogram: Dictionary, x_string_getter: Callable, y_string_getter: Callable, x_sort: Callable, y_magnitude: Callable, size: Vector2) -> void:
	_histogram = histogram
	_x_string_getter = x_string_getter
	_y_string_getter = y_string_getter
	_x_sort = x_sort
	_y_magnitude = y_magnitude
	_size = size
