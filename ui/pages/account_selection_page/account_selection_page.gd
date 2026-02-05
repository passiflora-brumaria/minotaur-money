extends VBoxContainer

## Sets the data models for this view.
func set_data (_data: Dictionary) -> void:
	pass

@onready var _self_scene: PackedScene = load("res://ui/pages/account_selection_page/account_selection_page.tscn")
@onready var _account_select_button_scene: PackedScene = preload("res://ui/pages/account_selection_page/components/account_select_button/account_select_button.tscn")
@onready var _account_view_page_scene: PackedScene = load("res://ui/pages/home_page/home_page.tscn")
@onready var _account_edit_page_scene: PackedScene = preload("res://ui/pages/account_edit_page/account_edit_page.tscn")

func _on_account_pressed (account: Account) -> void:
	var account_screen := _account_view_page_scene.instantiate()
	account_screen.set_data({
		"account": account,
		"date_of_viewing": Date.now()
	})
	Navigation.request_page(account_screen,null)

func _on_account_long_pressed (account: Account) -> void:
	var next_screen := _account_edit_page_scene.instantiate()
	next_screen.set_data({
		"account": account,
		"previous_page_scene": _self_scene,
		"previous_page_data": {}
	})
	Navigation.request_page(next_screen,null)
	queue_free()

func _on_account_creation_requested () -> void:
	var next_screen := _account_edit_page_scene.instantiate()
	next_screen.set_data({
		"account": null,
		"previous_page_scene": _self_scene,
		"previous_page_data": {}
	})
	Navigation.request_page(next_screen,null)
	queue_free()

func _ready () -> void:
	for a in AppData.data.accounts:
		var button := _account_select_button_scene.instantiate()
		button.account = a
		button.details_requested.connect(_on_account_pressed)
		button.edit_requested.connect(_on_account_long_pressed)
		add_child(button)
	var add_button := _account_select_button_scene.instantiate()
	add_button.account = null
	add_button.addition_requested.connect(_on_account_creation_requested)
	add_child(add_button)

func _notification (what: int) -> void:
	if (what == NOTIFICATION_WM_GO_BACK_REQUEST) || (what == NOTIFICATION_WM_CLOSE_REQUEST):
		if len(AppData.data.accounts) > 0:
			var previous_screen := _account_view_page_scene.instantiate()
			previous_screen.set_data({
				"account": AppData.data.accounts.get(0),
				"date_of_viewing": Date.now()
			})
			Navigation.request_page(previous_screen,null)
			queue_free()
		else:
			get_tree().exit()
