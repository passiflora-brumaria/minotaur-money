extends Node

@onready var page_container: PanelContainer = $"./MainUiLayer/Background"
@onready var fab_container: MarginContainer = $"./FloatingActionButtonLayer/MarginContainer"


func _on_page_changed (page: Control, fab: Control) -> void:
	while page_container.get_child_count() > 0:
		var removable: Node = page_container.get_child(0)
		page_container.remove_child(removable)
	if fab_container.get_child_count() == 1:
		var fab_to_remove: Node = fab_container.get_child(0)
		fab_container.remove_child(fab_to_remove)
	page_container.add_child(page)
	if fab != null:
		fab_container.add_child(fab)

func _ready () -> void:
	Navigation.page_requested.connect(_on_page_changed)
	#TEST ONLY
	print("Date test 1: " + str(Date.parse_iso("2001-01-01").is_prior_to(Date.parse_iso("2002-01-01"),true)))
	print("Date test 2: " + str(Date.parse_iso("2001-01-01").is_prior_to(Date.parse_iso("2001-03-01"),true)))
	print("Date test 3: " + str(Date.parse_iso("2001-01-01").is_prior_to(Date.parse_iso("2001-01-06"),true)))
	print("Date test 4: " + str(Date.parse_iso("2001-01-01").is_prior_to(Date.parse_iso("2001-01-01"),true)))
	print("Date test 5: " + str(Date.parse_iso("2001-01-01").is_prior_to(Date.parse_iso("2001-01-01"),false)))
	print(Decimal.parse("0.001",".").is_lesser_than(Decimal.parse("0.1",".")))
	print(Decimal.add([Decimal.parse("0.0001","."),Decimal.parse("-0.2",".")]))
	print(Decimal.add([Decimal.parse("3.01","."),Decimal.parse("-1.01","."),Decimal.parse("1.108","."),Decimal.parse("7.003","."),Decimal.parse("-5.0001","."),Decimal.parse("-6",".")]).to_string())
	print(Decimal.add([Decimal.parse("0","."),Decimal.parse("-0.1",".")]))

func _exit_tree () -> void:
	Navigation.page_requested.disconnect(_on_page_changed)
