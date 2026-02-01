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

@onready var _font: Font = preload("res://themes/normal_bold.ttf")

func _label_factory (text: String) -> Label:
	var new_label := Label.new()
	new_label.text = text
	new_label.add_theme_font_override("font",_font)
	new_label.add_theme_font_size_override("font_size",30)
	return new_label

func _get_x_axis (minimum_y_magnitude: float, maximum_y_magnitude: float, x_labels: Array[String], include_x_labels: bool) -> Line2D:
	var zero_ratio: float = (0.0 - minimum_y_magnitude) / (maximum_y_magnitude - minimum_y_magnitude)
	var zero_position: float = _size.y - (zero_ratio * (_size.y - 20.0) + 10.0)
	var line := Line2D.new()
	line.add_point(Vector2(100.0,zero_position))
	line.add_point(Vector2(_size.x - 10.0,zero_position))
	line.width = 5.0
	line.default_color = Color.BLACK
	if include_x_labels:
		for label_idx in range(len(x_labels)):
			var x_ratio: float = label_idx / (len(x_labels) - 1.0)
			var x_position: float = 100.0 + x_ratio * (_size.x - 100.0) + 5.0
			var y_position: float = zero_position + 5.0
			var rotation_angle: float = 0.3 * PI
			if zero_position > (_size.y - 100):
				y_position = zero_position - 5.0
				rotation_angle = -0.3 * PI
			var label := _label_factory(x_labels.get(label_idx))
			label.add_theme_font_size_override("font_size",12)
			label.rotation = rotation_angle
			label.set_position(Vector2(x_position,y_position))
			line.add_child(label)
	return line

func _get_y_axis () -> Line2D:
	var line := Line2D.new()
	line.add_point(Vector2(100,10.0))
	line.add_point(Vector2(100,_size.y - 10.0))
	line.width = 5.0
	line.default_color = Color.BLACK
	return line

func _get_line_and_point_list (y_point_list: Array[float], minimum_y_magnitude: float, maximum_y_magnitude: float) -> Array[Node2D]:
	var artifacts: Array[Node2D] = []
	var line := Line2D.new()
	for point_idx in range(len(y_point_list)):
		var x_ratio: float = point_idx / (len(y_point_list) - 1.0)
		var y_ratio: float = (y_point_list.get(point_idx) - minimum_y_magnitude) / (maximum_y_magnitude - minimum_y_magnitude)
		var centre_position: Vector2 = Vector2(110.0 + x_ratio * (_size.x - 120.0),_size.y - (y_ratio * (_size.y - 20.0) + 10.0))
		line.add_point(centre_position)
		var poly := Polygon2D.new()
		var polygon: PackedVector2Array = []
		for vertice_idx in range(8):
			var radius: float = 10.0 if (vertice_idx % 2 == 0) else 6.0
			var angle: float = (2.0 * PI) * (vertice_idx / 8.0)
			var vertice: Vector2 = Vector2(centre_position.x + radius * cos(angle),centre_position.y + radius * sin(angle))
			polygon.append(vertice)
		poly.polygon = polygon
		poly.color = Color.from_string("#FEFAE0",Color.WHITE)
		artifacts.append(poly)
	line.width = 2.5
	line.default_color = Color.from_string("#FEFAE0",Color.WHITE)
	artifacts.push_front(line)
	return artifacts

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
	if _histogram.size() < 2:
		push_error("Not enough data points to construct graph. Destroying graph attempt.")
		queue_free()
	#var background := Polygon2D.new()
	#background.color = Color.from_string("#FEFAE0",Color.BLACK)
	#background.polygon = [Vector2.ZERO,Vector2(0,_size.y),Vector2(_size.x,_size.y),Vector2(_size.x,0)]
	#add_child(background)
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
	var sorted_values := _histogram.values()
	sorted_values.sort_custom( func (a, b): return _y_magnitude.call(a,_histogram) < _y_magnitude.call(b,_histogram) )
	var minimum_y_magnitude: float = _y_magnitude.call(sorted_values.get(0),_histogram)
	var minimum_y_legend: String = _y_string_getter.call(sorted_values.get(0))
	var maximum_y_magnitude: float = _y_magnitude.call(sorted_values.get(len(sorted_values) - 1),_histogram)
	var maximum_y_legend: String = _y_string_getter.call(sorted_values.get(len(sorted_values) - 1))
	var minimum_y_label: Label = _label_factory(minimum_y_legend)
	minimum_y_label.set_position(Vector2(0,_size.y - 30))
	add_child(minimum_y_label)
	var maximum_y_label: Label = _label_factory(maximum_y_legend)
	maximum_y_label.set_position(Vector2.ZERO)
	add_child(maximum_y_label)
	add_child(_get_x_axis(minimum_y_magnitude,maximum_y_magnitude,data_points_x,len(data_points_x) < 10))
	add_child(_get_y_axis())
	var graph := _get_line_and_point_list(data_points_y,minimum_y_magnitude,maximum_y_magnitude)
	for element in graph:
		add_child(element)
