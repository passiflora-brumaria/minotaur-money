extends MarginContainer

## Account being edited, or null if this page is adding a new account.
@export var _account: Account

## Page to which to go back after the process is done.
@export var _previous_page_scene: PackedScene

## Data to send to the page to the previous page.
@export var _previous_page_data: Dictionary

## Sets the data models for this view.
func set_data (data: Dictionary) -> void:
	if data.has("account"):
		_account = data["account"]
	if data.has("previous_page_scene"):
		_previous_page_scene = data["previous_page_scene"]
	if data.has("previous_page_data"):
		_previous_page_data = data["previous_page_data"]

var _editable_model: Account

@onready var _integer_value_field: LineEdit = $"./Stack/ValueEdit/Integer"
@onready var _decimal_value_field: LineEdit = $"./Stack/ValueEdit/Decimal"

func _on_name_changed (new_value: String) -> void:
	_editable_model.name = new_value

func _on_value_text_changed (_v: String) -> void:
	_editable_model.starting_balance = Decimal.parse(_integer_value_field.text + "," + _decimal_value_field.text,",")

func _on_submitted () -> void:
	if _account != null:
		AppData.data.accounts.erase(_account)
	AppData.data.accounts.push_front(_editable_model)
	AppData.notify_changes()
	var previous_screen := _previous_page_scene.instantiate()
	previous_screen.set_data(_previous_page_data)
	Navigation.request_page(previous_screen,null)
	queue_free()

func _on_cancelled () -> void:
	var previous_screen := _previous_page_scene.instantiate()
	previous_screen.set_data(_previous_page_data)
	Navigation.request_page(previous_screen,null)
	queue_free()

func _ready () -> void:
	if _account != null:
		_editable_model = _account.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		$"./Stack/TitleRow/PageIcon".icon_name = "pen"
		$"./Stack/TitleRow/AccountTitle".text = _editable_model.name
	else:
		_editable_model = Account.new()
		$"./Stack/TitleRow/PageIcon".icon_name = "circle-plus"
		$"./Stack/TitleRow/AccountTitle".text = tr("ADD_NEW_ACCOUNT")
	$"./Stack/NameEdit".text_changed.connect(_on_name_changed)
	if _editable_model.starting_balance == null:
		_editable_model.starting_balance = Decimal.construct(0,[],false)
	_integer_value_field.text = str(_editable_model.starting_balance.get_integer_part())
	_decimal_value_field.text = _editable_model.starting_balance.get_decimal_part()
	_integer_value_field.text_changed.connect(_on_value_text_changed)
	_decimal_value_field.text_changed.connect(_on_value_text_changed)
	$"./Stack/Submit".pressed.connect(_on_submitted)

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		if _previous_page_scene != null:
			var previous_screen := _previous_page_scene.instantiate()
			previous_screen.set_data(_previous_page_data)
			Navigation.request_page(previous_screen,null)
			queue_free()
		else:
			get_tree().exit()
