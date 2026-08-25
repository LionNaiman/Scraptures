class_name ScraptureRuntime
extends Resource


var definition: ScraptureDefinition
var current_health: int = 0 
var equipped_modules: Array[ModuleDefinition] = [] #this is the array that will be used to store the equipped modules

func initialize(scrapture_definition: ScraptureDefinition) -> void:
	definition = scrapture_definition
	current_health = definition.base_max_health #this is the command that will be sent to the current health variable

func equip_module(module: ModuleDefinition) -> bool:
	if not can_equip_module(module):
		return false

	equipped_modules.append(module)
	return true


func get_used_capacity() -> int:
	var total: int = 0

	for module: ModuleDefinition in equipped_modules:
		total += module.capacity_cost

	return total

func get_remaining_capacity() -> int:
	return definition.attachment_capacity - get_used_capacity() #this is the command that will be sent to the remaining capacity function

func can_equip_module(module: ModuleDefinition) -> bool:
	return module.capacity_cost <= get_remaining_capacity() #this is the command that will be sent to the can equip module function

func unequip_module(module: ModuleDefinition) -> bool: #this is the function that will be called to unequip a module
	if not equipped_modules.has(module):
		return false

	equipped_modules.erase(module)
	current_health = min(current_health, get_final_max_health()) #this is the command that will be sent to the current health variable
	return true 

func get_final_speed() -> int: #this is the function that will be called to get the final speed
	var final_speed: int = definition.base_speed

	for module: ModuleDefinition in equipped_modules:
		final_speed += module.speed_bonus

	return final_speed

func get_final_max_health() -> int:
	var final_max_health: int = definition.base_max_health

	for module: ModuleDefinition in equipped_modules:
		final_max_health += module.max_health_bonus

	return final_max_health 

