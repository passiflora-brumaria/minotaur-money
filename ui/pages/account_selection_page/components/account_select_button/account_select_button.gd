extends PanelContainer

## Account selected with this button. If null, this will be the "add new account" button.
@export var account: Account
var _press_duration: float

## Signal fired when the details page on the account has been requested.
signal details_requested (acc: Account)

## Signal fired when the edit page on the account has been requested.
signal edit_requested (acc: Account)

## Signal fired when a new account is to be added.
signal addition_requested ()

func _on_pressed () -> void:
	_press_duration = 0.0
	$"./Overlay".color = Color.from_rgba8(24,24,24,100)

func _on_released () -> void:
	if _press_duration > 1.0:
		edit_requested.emit(account)
	elif _press_duration > -0.5:
		details_requested.emit(account)
	_press_duration = -1.0
	$"./Overlay".color = Color.TRANSPARENT

func _on_addition_requested () -> void:
	addition_requested.emit()
	_press_duration = -1.0
	$"./Overlay".color = Color.TRANSPARENT

func _ready () -> void:
	_press_duration = -1.0
	$"./Overlay".custom_minimum_size = get_minimum_size()
	$"./Input".position = 0.5 * get_rect().size
	$"./Input".shape.size = get_rect().size
	if account != null:
		$"./AcbPadding/Label".text = account.name
		$"./Input".pressed.connect(_on_pressed)
		$"./Input".released.connect(_on_released)
		if account == AppData.data.accounts.get(0):
			var panel : StyleBoxFlat = get_theme_stylebox("panel").duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			panel.bg_color = Color.from_string("#FAEDCD",Color.MEDIUM_PURPLE)
			add_theme_stylebox_override("panel",panel)
	else:
		$"./AcbPadding/Label".text = tr("ADD_NEW_ACCOUNT")
		$"./Input".pressed.connect(_on_pressed)
		$"./Input".released.connect(_on_addition_requested)
		var panel : StyleBoxFlat = get_theme_stylebox("panel").duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		panel.bg_color = Color.from_string("#E9EDC9",Color.ORANGE)
		panel.border_width_bottom = 2
		print ("Add account button has border with width" + str(panel.border_width_bottom) + " and colour " + str(panel.border_color) + ".")
		add_theme_stylebox_override("panel",panel)

func _process (delta: float) -> void:
	if _press_duration > -0.5:
		_press_duration += delta
		if _press_duration > 1.0:
			_on_released()
