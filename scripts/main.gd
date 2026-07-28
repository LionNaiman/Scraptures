extends Node2D
#@oneready - initiatlize the variable only once the node and the child exist
#$ScrapLabel - find the child of the current node named scrapLabel
@onready var scrap_label: Label = $ScrapLabel
@onready var goal_label: Label = $GoalLabel
var scrap_count: int = 0
@export var scrap_goal: int = 3


func _ready() -> void:
	connect_scrap_signals() #calls one time this func once we enter the scene 
	update_scrap_label() #display the label text right away



func connect_scrap_signals() -> void:
	var scrap_nodes: Array[Node] = get_tree().get_nodes_in_group("scrap") #asks the scene tree all the nodes in this group

	for node: Node in scrap_nodes:
		var scrap: Scrap = node as Scrap

		if scrap != null:
			scrap.collected.connect(_on_scrap_collected) #connects each scrap to the scrap collection method 


func _on_scrap_collected() -> void:
	scrap_count += 1
	update_scrap_label() #call the display function 
	check_scrap_goal()
	print("Scrap collected. Total: ", scrap_count)

func update_scrap_label() -> void: #a function which dispalyes the text of the label 
	scrap_label.text = (
		"Scrap: "
		+ str(scrap_count)
		+ " / "
		+ str(scrap_goal)
	)
#a function to check if we have reached our goal
func check_scrap_goal() -> void:
	if scrap_count >= scrap_goal:
		goal_label.text = "All Scrap Collected!"
