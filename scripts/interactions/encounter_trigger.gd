class_name EncounterTrigger
extends Area2D


signal encounter_triggered(scrapture_definition: ScraptureDefinition)

@export var scrapture_definition: ScraptureDefinition


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if scrapture_definition == null:
		push_warning("EncounterTrigger has no ScraptureDefinition assigned.")
		return

	print("Encounter triggered")
	encounter_triggered.emit(scrapture_definition)
	queue_free()
