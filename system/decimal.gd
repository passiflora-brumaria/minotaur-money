## Fixed-point decimal number.
class_name Decimal extends Resource

## Integer part of the number. Must be 0 or greater.
@export var _integer_part: int

## Decimal part of the number. Stored as a digit array.
@export var _decimal_part: PackedInt32Array

## Whether the number is negative.
@export var _is_negative: bool

## Parse a decimal number from a string.
static func parse (string: String, decimal_delimiter: String = ",") -> Decimal:
	var read_decimal := Decimal.new()
	var terms: PackedStringArray = string.split(decimal_delimiter)
	terms[0] = terms[0].replace(" ","")
	if len(terms) == 1:
		read_decimal._integer_part = int(terms[0])
		read_decimal._decimal_part = [0,0]
	elif len(terms) == 2:
		read_decimal._integer_part = int(terms[0])
		read_decimal._decimal_part = []
		for idx in range(terms[1].length()):
			var digit: String = terms[1].substr(idx,1)
			read_decimal._decimal_part.push_back(int(digit))
	if (read_decimal._integer_part < 0) || (string.substr(0,1) == "-"):
		read_decimal._is_negative = true
		read_decimal._integer_part = abs(read_decimal._integer_part)
	return read_decimal

## Creates a decimal number given an integer part, decimal digits and a sign.
static func construct (integer_part_abs: int, decimal_digits: PackedInt32Array, negative: bool) -> Decimal:
	var new_dec: Decimal = Decimal.new()
	new_dec._integer_part = abs(integer_part_abs)
	new_dec._decimal_part = decimal_digits.duplicate()
	new_dec._is_negative = negative
	return new_dec

static func _invert_decimals (decimals: PackedInt32Array) -> int:
	var carry: int = 0
	for idx in range(len(decimals)):
		var digit: int = decimals[len(decimals) - (idx + 1)]
		var res: int = digit + carry - 10
		if res < 0:
			carry = 1
		else:
			carry = 0
		decimals[len(decimals) - (idx + 1)] = abs(res) % 10
	return carry * -1

## Performs an addition. All factors are assumed to be positive; if they're not, the operation will fail to produce a correct result.
static func add (factors: Array[Decimal]) -> Decimal:
	var total_integer: int = 0
	var total_decimal: PackedInt32Array = [0]
	var is_total_negative: bool = false
	for factor in factors:
		#print("Adding " + factor.to_string())
		if factor._is_negative != is_total_negative:
			var will_cross_sign: bool = construct(total_integer,total_decimal,false).is_lesser_than(factor.get_absolute_value())
			total_integer -= factor._integer_part
			var decimal_addable: PackedInt32Array = factor._decimal_part.duplicate()
			while len(decimal_addable) > len(total_decimal):
				total_decimal.push_back(0)
			while len(decimal_addable) < len(total_decimal):
				decimal_addable.push_back(0)
			var carry: int = 0
			for idx in range(len(decimal_addable)):
				var digit_result: int = total_decimal[len(total_decimal) - (1 + idx)] - decimal_addable[len(total_decimal) - (1 + idx)] + carry
				if digit_result < 0:
					carry = -1
					if (idx > 0) || (total_integer != 0) || will_cross_sign:
						digit_result = 10 + digit_result
				else:
					carry = digit_result / 10
				total_decimal[len(total_decimal) - (1 + idx)] = abs(digit_result) % 10
			if will_cross_sign:
				is_total_negative = !is_total_negative
				carry = _invert_decimals(total_decimal)
			if (total_integer == 0) && (carry == -1) && will_cross_sign:
				carry = 0
			total_integer = abs(abs(total_integer) + carry)
		else:
			total_integer += factor._integer_part
			var decimal_addable: PackedInt32Array = factor._decimal_part.duplicate()
			while len(decimal_addable) > len(total_decimal):
				total_decimal.push_back(0)
			while len(decimal_addable) < len(total_decimal):
				decimal_addable.push_back(0)
			var carry: int = 0
			for idx in range(len(decimal_addable)):
				var digit_result: int = total_decimal[len(total_decimal) - (1 + idx)] + decimal_addable[len(total_decimal) - (1 + idx)] + carry
				carry = digit_result / 10
				total_decimal[len(total_decimal) - (1 + idx)] = digit_result % 10
			if carry > 0:
				total_integer += carry
	var result := Decimal.new()
	result._integer_part = total_integer
	result._decimal_part = total_decimal
	result._is_negative = is_total_negative
	result._get_decimal_part_string()
	return result

## Gets the integer part of this number.
func get_integer_part () -> int:
	return _integer_part

## Gets the decimal part of this number (the digits after the comma).
func get_decimal_part () -> String:
	var dps: String = _get_decimal_part_string()
	if len(dps) == 0:
		return "00"
	return dps

## Returns a copy of this number.
func copy () -> Decimal:
	return duplicate_deep(DEEP_DUPLICATE_ALL)

## Returns the absolute value of this number.
func get_absolute_value () -> Decimal:
	var n: Decimal = copy()
	n._is_negative = false
	return n

## Returns the opposite of this number (same absolute value, inverted sign).
func opposite () -> Decimal:
	var n: Decimal = copy()
	n._is_negative = !n._is_negative
	return n

## Returns whether this number is lesser than another.
func is_lesser_than (other: Decimal) -> bool:
	if _integer_part == other._integer_part:
		if _is_negative == other._is_negative:
			if !_is_negative:
				var decimal_digit_index: int = 0
				var this_ddigits: int = len(_decimal_part)
				var other_ddigits: int = len(other._decimal_part)
				var max_ddigits: int = max(this_ddigits,other_ddigits)
				while decimal_digit_index < max_ddigits:
					var this_ddigit: int = 0
					if decimal_digit_index < this_ddigits:
						this_ddigit = _decimal_part[decimal_digit_index]
					var other_ddigit: int = 0
					if decimal_digit_index < other_ddigits:
						other_ddigit = other._decimal_part[decimal_digit_index]
					if this_ddigit == other_ddigit:
						decimal_digit_index += 1
					else:
						return this_ddigit < other_ddigit
				return false
			else:
				return other.get_absolute_value().is_lesser_than(get_absolute_value())
		else:
			return _is_negative
	else:
		return (_integer_part * (-1 if _is_negative else 1)) < (other._integer_part * (-1 if other._is_negative else 1))

func _get_integer_part_string (separate_e3: bool = true) -> String:
	var result = str(_integer_part)
	if separate_e3:
		var processed_characters: int = 0
		while len(result) > (processed_characters + 3):
			processed_characters += 3
			result.insert(len(result) - processed_characters," ")
			processed_characters += 1
	return result

func _get_decimal_part_string () -> String:
	while (len(_decimal_part) > 0) && (_decimal_part[len(_decimal_part) - 1] == 0):
		_decimal_part.remove_at(len(_decimal_part) - 1)
	var result: String = ""
	for digit in _decimal_part:
		result += str(digit)
	return result

func _to_string (decimal_separator: String = ",", separate_thousands: bool = true) -> String:
	var prefix: String = "-" if _is_negative else ""
	var decimal_string: String = _get_decimal_part_string()
	if len(decimal_string) == 0:
		return prefix + _get_integer_part_string(separate_thousands)
	else:
		return prefix + _get_integer_part_string(separate_thousands) + decimal_separator + decimal_string
