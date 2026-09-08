extends Node2D
#@oneready - initiatlize the variable only once the node and the child exist
#$ScrapLabel - find the child of the current node named scrapLabel
@onready var scrap_label: Label = $ScrapLabel
@onready var goal_label: Label = $GoalLabel
var scrap_count: int = 0
@export var scrap_goal: int = 3
var module_inventory: ModuleInventory = ModuleInventory.new() #this is the array that will be used to store the collected modules
@export var starter_definition: ScraptureDefinition #this is the definition that will be used to store the starter scrapture
var starter_scrapture: ScraptureRuntime #this is the scrapture that will be used to store the starter scrapture
var scrapture_party: Array[ScraptureRuntime] = []
var selected_scrapture: ScraptureRuntime #this is the scrapture that will be used to store the selected scrapture
@export var fast_wild_definition: ScraptureDefinition #enemy var
var enemy_scrapture: ScraptureRuntime
@onready var inventory_screen: InventoryScreen = $InventoryScreen
@onready var player: CharacterBody2D = $Player
@onready var battle: Battle = $Battle 


func _ready() -> void: 
	connect_module_pickup_signals() #connect the module pickup signals
	update_scrap_label() #display the label text right away
	create_starter_scrapture() #create the starter scrapture
	battle.battle_ended.connect(_on_battle_ended) #battle ended signal connection
	battle.scrapture_captured.connect(_on_scrapture_captured) #scrapture captured signal connection
	

	

	# Display the scrapture and inventory 
	inventory_screen.display_scrapture(selected_scrapture) # Display the scrapture in the inventory screen
	inventory_screen.display_inventory(module_inventory)
	inventory_screen.equip_requested.connect(_on_equip_requested) #connect the equip requested signal to the _on_equip_requested function
	inventory_screen.unequip_requested.connect(_on_unequip_requested) #connect the unequip requested signal to the _on_unequip_requested function
	inventory_screen.scrapture_selected.connect(
	_on_scrapture_selected
)
func _on_unequip_requested(module: ModuleDefinition) -> void:
	var unequipped_successfully: bool = try_unequip_module_to_inventory(module)

	if not unequipped_successfully:
		return

	inventory_screen.show_feedback("")
	inventory_screen.display_inventory(module_inventory)
	inventory_screen.display_scrapture(starter_scrapture)

func _on_battle_ended() -> void:
	player.set_process_unhandled_input(true)
	print_party()

func _on_scrapture_captured(scrapture: ScraptureRuntime) -> void:
	if scrapture == null:
		return

	if scrapture_party.has(scrapture):
		return

	scrapture_party.append(scrapture)
	inventory_screen.display_party(scrapture_party)

	print(
		"Added to party: ",
		scrapture.definition.display_name
	)

	print(
		"Party size: ",
		scrapture_party.size()
	)

func _on_scrapture_selected(
	scrapture: ScraptureRuntime
) -> void:
	if not scrapture_party.has(scrapture):
		return

	selected_scrapture = scrapture

	inventory_screen.display_scrapture(
		selected_scrapture
	)

	inventory_screen.show_feedback("")
func _on_equip_requested(module: ModuleDefinition) -> void:
	var equipped_successfully: bool = try_equip_module_from_inventory(module)

	if not equipped_successfully:
		inventory_screen.show_feedback(
			"Not enough Attachment Capacity."
		)
		return

	inventory_screen.show_feedback("")
	inventory_screen.display_inventory(module_inventory)
	inventory_screen.display_scrapture(selected_scrapture)

func create_starter_scrapture() -> void: #this is the function that will be called to create the starter scrapture
	if starter_definition == null:
		push_warning("Main has no starter ScraptureDefinition assigned.")
		return

	starter_scrapture = ScraptureRuntime.new()
	starter_scrapture.initialize(starter_definition)
	scrapture_party.append(starter_scrapture)
	selected_scrapture = starter_scrapture
	print("Starter: ", starter_scrapture.definition.display_name)
	print("Starting health: ", starter_scrapture.current_health)

func create_enemy_scrapture() -> void:
	if fast_wild_definition == null:
		push_warning("Main has no Fast Wild ScraptureDefinition assigned.")
		return

	enemy_scrapture = ScraptureRuntime.new()
	enemy_scrapture.initialize(fast_wild_definition)

func _unhandled_input(event: InputEvent) -> void: #this is the function that will be called when the input is received
	if event.is_action_pressed("inventory"):
		if battle.is_active():
			return

		inventory_screen.visible = not inventory_screen.visible
		player.set_process_unhandled_input(not inventory_screen.visible)
	if event.is_action_pressed("test_battle"):
		start_test_battle()
	if event.is_action_pressed("battle_basic_attack"):
		battle.perform_basic_attack_round()
	if event.is_action_pressed("battle_guard"):
		battle.perform_guard_round()
	if event.is_action_pressed("battle_module_move"):
		battle.perform_granted_move_at_index(0)
	if event.is_action_pressed("battle_module_move_2"):
		battle.perform_granted_move_at_index(1)	
	if event.is_action_pressed("battle_capture"):
		battle.perform_capture_attempt()



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
	inventory_screen.display_inventory(module_inventory) #this is the command that will be sent to the display inventory function
	scrap_count += 1 #this is the command that will be sent to the scrap count variable
	update_scrap_label() #this is the command that will be sent to the update scrap label function
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



func try_equip_module_from_inventory(
	module: ModuleDefinition
) -> bool:
	if selected_scrapture == null:
		return false

	if not module_inventory.has_module(module):
		return false

	if not selected_scrapture.can_equip_module(module):
		return false

	module_inventory.remove_module(module)
	selected_scrapture.equip_module(module)

	return true




func try_unequip_module_to_inventory(
	module: ModuleDefinition
) -> bool:
	if selected_scrapture == null:
		return false

	if not selected_scrapture.unequip_module(module):
		return false

	module_inventory.add_module(module)

	return true


func print_party() -> void:
	print("----- PARTY -----")

	for scrapture: ScraptureRuntime in scrapture_party:
		print(
			scrapture.definition.display_name,
			" HP: ",
			scrapture.current_health,
			" / ",
			scrapture.get_final_max_health()
		)

	print("Party size: ", scrapture_party.size())
	print("-----------------")


func start_test_battle() -> void:
	if battle.is_active():
		return

	if starter_scrapture.is_defeated():
		print("Starter is defeated and cannot battle.")
		return

	inventory_screen.visible = false

	create_enemy_scrapture()
	battle.initialize(starter_scrapture, enemy_scrapture)

	player.set_process_unhandled_input(false)
