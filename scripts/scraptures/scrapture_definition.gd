class_name ScraptureDefinition # egisters a globally recognized Godot type. Other scripts will later be able to write: var definition: ScraptureDefinition
extends Resource # A Resource is a data container that can be saved to a file and loaded from a file.


@export var display_name: String = ""
@export var base_max_health: int = 10
@export var base_speed: int = 5
@export var attachment_capacity: int = 3