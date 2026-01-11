extends Node

## Signal fired when a new UI page has been requested.
signal page_requested (page: Control, fab: Control)

## Requests a page change wit the page UI and an optional floating action button.
func request_page (page: Control, fab: Control) -> void:
	page_requested.emit(page,fab)
