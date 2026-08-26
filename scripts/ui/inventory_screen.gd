class_name InventoryScreen
extends Control
signal equip_requested(module: ModuleDefinition)
signal unequip_requested(module: ModuleDefinition)




@onready var loadout_panel: LoadoutPanel = ( # Loadout panel to display the loadout
	$Panel/Content/LoadoutPanel
)
@onready var equip_button: Button = ( # Button to equip a module
	$Panel/Content/EquipButton
)
@onready var unequip_button: Button = ( # Button to unequip a module
	$Panel/Content/UnequipButton
)

@onready var available_modules_option_button: OptionButton = ( # Option button to display the available modules
	$Panel/Content/AvailableModulesOptionButton
)

@onready var equipped_modules_option_button: OptionButton = (
	$Panel/Content/EquippedModulesOptionButton
) 
@onready var feedback_label: Label = (
	$Panel/Content/FeedbackLabel
)

var selected_module: ModuleDefinition
var displayed_modules: Array[ModuleDefinition] = []
var selected_equipped_module: ModuleDefinition
var displayed_equipped_modules: Array[ModuleDefinition] = []


func show_feedback(message: String) -> void:
	feedback_label.text = message

	
func display_inventory(inventory: ModuleInventory) -> void:
	displayed_modules = inventory.get_modules()
	if inventory.get_count() == 0:
		selected_module = null
		available_modules_option_button.clear()
		available_modules_option_button.disabled = true
		equip_button.disabled = true
		return
	available_modules_option_button.clear()
	available_modules_option_button.disabled = false
	equip_button.disabled = false

	for module: ModuleDefinition in inventory.get_modules():
		available_modules_option_button.add_item(module.display_name)
		
	selected_module = inventory.get_modules()[0]

func display_scrapture(scrapture: ScraptureRuntime) -> void: # Function to display the scrapture
	loadout_panel.display_scrapture(scrapture)

	equipped_modules_option_button.clear()
	displayed_equipped_modules = scrapture.equipped_modules

	if displayed_equipped_modules.is_empty():
		selected_equipped_module = null
		equipped_modules_option_button.disabled = true
		unequip_button.disabled = true
		return

	equipped_modules_option_button.disabled = false
	unequip_button.disabled = false

	for module: ModuleDefinition in displayed_equipped_modules:
		equipped_modules_option_button.add_item(module.display_name)

	selected_equipped_module = displayed_equipped_modules[0] #this is the command that will be sent to the selected equipped module variable to display the first equipped module

func _on_equip_button_pressed() -> void: # Function to equip a module
	if selected_module == null: #this is the command that will be sent to the selected module variable
		return

	equip_requested.emit(selected_module) #this is the command that will be sent to the equip requested signal
	

func _on_unequip_button_pressed() -> void: # Function to unequip a module
	if selected_equipped_module == null: #this is the command that will be sent to the selected equipped module variable
		return #this is the command that will be sent to the return function

	unequip_requested.emit(selected_equipped_module) #this is the command that will be sent to the unequip requested signal

func _on_available_modules_option_button_item_selected(index: int) -> void:
	selected_module = displayed_modules[index]


func _on_equipped_modules_option_button_item_selected(index: int) -> void:
	selected_equipped_module = displayed_equipped_modules[index]
