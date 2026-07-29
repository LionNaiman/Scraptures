class_name ModulePickup
extends Area2D


signal collected(module: ModuleDefinition)

@export var module_definition: ModuleDefinition


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if module_definition == null:
		push_warning("Module pickup has no ModuleDefinition assigned.")
		return

	collected.emit(module_definition)
	queue_free()
