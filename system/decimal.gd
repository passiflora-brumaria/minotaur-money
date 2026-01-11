## Fixed-point decimal number.
class_name Decimal extends Resource

## Integer part of the number.
@export var integer_part: int

## Decimal part of the number.
@export var decimal_part: int

## Parse a decimal number from a string.
static func parse (string: String, decimal_delimiter: String = ".") -> Decimal:
	var read_decimal := Decimal.new()
	var terms: PackedStringArray = string.split(decimal_delimiter)
	if len(terms) == 1:
		read_decimal.integer_part = int(terms[0])
		read_decimal.decimal_part = 0
	elif len(terms) == 2:
		read_decimal.integer_part = int(terms[0])
		read_decimal.decimal_part = int(terms[1])
	return read_decimal

static func add (factors: Array[Decimal]) -> Decimal:
	var total_integer: int = 0
	var decimal_digit_number: int = 0
	var total_decimal: int = 0
	for factor in factors:
		total_integer += factor.integer_part
		var decimal_digits: int = int(floor(log(factor.decimal_part) / log(10)))
		var modulus_checker: int = int(pow(10,decimal_digits)) * 10
		print("Modulus checker for " + factor.to_string() + " is " + str(modulus_checker) + ".")
		if total_integer == 0:
			decimal_digit_number = decimal_digits
			total_integer = factor.decimal_part
		elif decimal_digits > decimal_digit_number:
			total_decimal *= int(pow(10,decimal_digits - decimal_digit_number))
			total_decimal += factor.decimal_part
		else:
			modulus_checker = int(pow(10,decimal_digit_number)) * 10
			var addable_decimal: int = factor.decimal_part * int(pow(10,decimal_digit_number - decimal_digits))
			total_decimal += addable_decimal
		if total_decimal >= modulus_checker:
			total_integer += total_decimal / modulus_checker
			total_decimal = total_decimal % modulus_checker
		print("Just added " + factor.to_string() + ". Value is now " + str(total_integer) + "." + str(total_decimal) + ".")
	var result := Decimal.new()
	result.integer_part = total_integer
	result.decimal_part = total_decimal
	return result

func _to_string (decimal_separator: String = ".") -> String:
	return str(integer_part) + decimal_separator + str(decimal_part)
