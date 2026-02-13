extends MarginContainer

var _transaction: TransactionHistoryEntry

func set_data (transaction: TransactionHistoryEntry) -> void:
	_transaction = transaction

signal edit_requested (model: TransactionHistoryEntry)

func _on_pressed () -> void:
	$"./InteractiveOverlay".color = Color.from_rgba8(24,24,24,100)

func _on_released () -> void:
	$"./InteractiveOverlay".color = Color.TRANSPARENT
	edit_requested.emit(_transaction)

func _ready () -> void:
	$"./Title".add_theme_color_override("font_color",_transaction.get_colour())
	$"./Title".text = _transaction.get_title()
	$"./Subtitle".add_theme_color_override("font_color",_transaction.get_colour())
	$"./Subtitle".text = _transaction.get_description()
	$"./Value".add_theme_color_override("font_color",_transaction.get_colour())
	$"./Value".text = _transaction.get_value().to_string() + " €"
	$"./TapToEdit".add_theme_color_override("font_color",_transaction.get_colour())
	$"./GestureDetector".position = 0.5 * get_rect().size
	$"./GestureDetector".shape.size = get_rect().size
	$"./GestureDetector".pressed.connect(_on_pressed)
	$"./GestureDetector".released.connect(_on_released)
