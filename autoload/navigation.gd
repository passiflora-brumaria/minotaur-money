extends Node

## Signal fired when a new UI page has been requested.
signal page_requested (page: Control, fab: Control, force_deletion_of_previous_page: bool)

func _process (_delta: float) -> void:
	if Input.is_action_just_released("ui_cancel") || (OS.has_feature("debug") && Input.is_action_just_released("emulate_back_button")):
		get_tree().get_first_node_in_group("__currentpage__").propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

## Requests a page change wit the page UI and an optional floating action button.
func request_page (page: Control, fab: Control, force_deletion_of_previous_page: bool = false) -> void:
	for p in get_tree().get_nodes_in_group("__currentpage__"):
		p.remove_from_group("__current_page__")
	page.add_to_group("__currentpage__")
	page_requested.emit(page,fab,force_deletion_of_previous_page)
