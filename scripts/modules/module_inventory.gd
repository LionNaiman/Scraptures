class_name ModuleInventory #this is the class that will be used to store the collected modules
extends Resource 


var modules: Array[ModuleDefinition] = [] #this is the array that will be used to store the collected modules           


func add_module(module: ModuleDefinition) -> void:
	modules.append(module) #this is the command that will be sent to the add module function


func get_count() -> int:
	return modules.size() #this is the command that will be sent to the get count function

func get_modules() -> Array[ModuleDefinition]:
	return modules #this is the command that will be sent to the get modules function