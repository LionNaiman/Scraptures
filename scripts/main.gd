extends Node2D
#@oneready - initiatlize the variable only once the node and the child exist
#$ScrapLabel - find the child of the current node named scrapLabel
@onready var scrap_label: Label = $ScrapLabel
@onready var goal_label: Label = $GoalLabel
var scrap_count: int = 0
@export var scrap_goal: int = 3
var module_inventory: ModuleInventory = ModuleInventory.new() #this is the array that will be used to store the collected modules
@onready var module_list_label: Label = $ModuleListLabel #this is the label that will be used to display the list of collected modules

func _ready() -> void:
	connect_module_pickup_signals() #connect the module pickup signals
	update_scrap_label() #display the label text right away
	update_module_list_label() #display the label text right away


func connect_module_pickup_signals() -> void:
	var module_pickup_nodes: Array[Node] = (
		get_tree().get_nodes_in_group("module_pickup")
	)

	for node: Node in module_pickup_nodes:
		var module_pickup: ModulePickup = node as ModulePickup

		if module_pickup != null:
			module_pickup.collected.connect(_on_module_collected)

#this is the function that will be called when the module is collected
func _on_module_collected(module: ModuleDefinition) -> void:
	module_inventory.add_module(module) #this is the command that will be sent to the collected modules array
	scrap_count += 1 #this is the command that will be sent to the scrap count variable
	update_scrap_label() #this is the command that will be sent to the update scrap label function
	update_module_list_label() #this is the command that will be sent to the update module list label function
	check_scrap_goal() #this is the command that will be sent to the check scrap goal function

	print("Collected module: ", module.display_name) #this is the command that will be sent to the print function
	print("Modules owned: ", module_inventory.get_count()) #this is the command that will be sent to the print function


func update_scrap_label() -> void: #this is the function that will be called to update the scrap label
	scrap_label.text = (
		"Scrap: " #this is the text that will be displayed in the scrap label
		+ str(scrap_count)
		+ " / "
		+ str(scrap_goal) #this is the text that will be displayed in the scrap goal label
	)
#a function to check if we have reached our goal
func check_scrap_goal() -> void: #this is the function that will be called to check if we have reached our goal
	if scrap_count >= scrap_goal:
		goal_label.text = "All Scrap Collected!" #this is the text that will be displayed in the goal label

func update_module_list_label() -> void:
	module_list_label.text = "Modules:" #this is the text that will be displayed in the module list label

	for module: ModuleDefinition in module_inventory.get_modules():
		module_list_label.text += "\n" + module.display_name #this is the text that will be displayed in the module list label
