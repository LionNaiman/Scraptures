class_name MoveDefinition
extends Resource
enum MoveKind {
	DAMAGE,
	GUARD
}

@export var display_name: String = ""
@export var damage: int = 0
@export var move_kind: MoveKind = MoveKind.DAMAGE
