extends Node

@onready var page_container: PanelContainer = $"./MainUiLayer/Background"
@onready var fab_container: MarginContainer = $"./FloatingActionButtonLayer/MarginContainer"


func _on_page_changed (page: Control, fab: Control) -> void:
	while page_container.get_child_count() > 0:
		var deletable: Node = page_container.get_child(0)
		page_container.remove_child(deletable)
		deletable.queue_free()
	if fab_container.get_child_count() == 1:
		var fab_to_delete: Node = fab_container.get_child(0)
		fab_container.remove_child(fab_to_delete)
		fab_to_delete.queue_free()
	page_container.add_child(page)
	if fab != null:
		fab_container.add_child(fab)

func _ready () -> void:
	Navigation.page_requested.connect(_on_page_changed)
	#TEST ONLY
	print(Decimal.parse("0.001",".").is_lesser_than(Decimal.parse("0.1",".")))
	print(Decimal.add([Decimal.parse("0.0001","."),Decimal.parse("-0.2",".")]))
	print(Decimal.add([Decimal.parse("3.01","."),Decimal.parse("-1.01","."),Decimal.parse("1.108","."),Decimal.parse("7.003","."),Decimal.parse("-5.0001","."),Decimal.parse("-6",".")]).to_string())
	print(Decimal.add([Decimal.parse("0","."),Decimal.parse("-0.1",".")]))

func _exit_tree () -> void:
	Navigation.page_requested.disconnect(_on_page_changed)
