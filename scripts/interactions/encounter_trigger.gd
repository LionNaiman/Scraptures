class_name EncounterTrigger
extends Area2D

signal encounter_triggered(
	scrapture_definition: ScraptureDefinition
)

@export var scrapture_definition: ScraptureDefinition

@onready var scrapture_sprite: Sprite2D = $ScraptureSprite


func _ready() -> void:
	if scrapture_definition == null:
		return

	scrapture_sprite.texture = scrapture_definition.overworld_texture


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if scrapture_definition == null:
		push_warning(
			"EncounterTrigger has no ScraptureDefinition assigned."
		)
		return

	encounter_triggered.emit(scrapture_definition)
	queue_free()
