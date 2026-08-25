extends Node2D
#@oneready - initiatlize the variable only once the node and the child exist
#$ScrapLabel - find the child of the current node named scrapLabel
@onready var scrap_label: Label = $ScrapLabel
@onready var goal_label: Label = $GoalLabel
var scrap_count: int = 0
@export var scrap_goal: int = 3
var module_inventory: ModuleInventory = ModuleInventory.new() #this is the array that will be used to store the collected modules
@onready var module_list_label: Label = $ModuleListLabel #this is the label that will be used to display the list of collected modules
@export var starter_definition: ScraptureDefinition #this is the definition that will be used to store the starter scrapture
var starter_scrapture: ScraptureRuntime #this is the scrapture that will be used to store the starter scrapture
@onready var loadout_panel: LoadoutPanel = $LoadoutPanel

func _ready() -> void:
	connect_module_pickup_signals() #connect the module pickup signals
	update_scrap_label() #display the label text right away
	update_module_list_label() #display the label text right away
	create_starter_scrapture() #create the starter scrapture
	loadout_panel.display_scrapture(starter_scrapture)
	
func create_starter_scrapture() -> void: #this is the function that will be called to create the starter scrapture
	if starter_definition == null:
		push_warning("Main has no starter ScraptureDefinition assigned.")
		return

	starter_scrapture = ScraptureRuntime.new()
	starter_scrapture.initialize(starter_definition)

	print("Starter: ", starter_scrapture.definition.display_name)
	print("Starting health: ", starter_scrapture.current_health)

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

func try_equip_module_from_inventory(module: ModuleDefinition) -> bool: #this is the function that will be called to try to equip a module from the inventory
	if not module_inventory.has_module(module):
		return false

	if not starter_scrapture.can_equip_module(module):
		return false

	module_inventory.remove_module(module)
	starter_scrapture.equip_module(module)
	update_module_list_label() #this is the command that will be sent to the update module list label function

	return true




func try_unequip_module_to_inventory(module: ModuleDefinition) -> bool:
	if not starter_scrapture.unequip_module(module):
		return false

	module_inventory.add_module(module)
	update_module_list_label()

	return true
