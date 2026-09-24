class_name EncounterTrigger
extends Area2D

signal encounter_triggered(
	scrapture_definition: ScraptureDefinition
)

@export var scrapture_definition: ScraptureDefinition

@export var wander_enabled: bool = true
@export var wander_radius_tiles: int = 1

const GRID_SIZE: float = 32.0
const WANDER_MOVE_DURATION: float = 0.35

var spawn_position: Vector2
var is_moving: bool = false

@onready var scrapture_sprite: Sprite2D = $ScraptureSprite


func _ready() -> void:
	spawn_position = position

	if scrapture_definition == null:
		return

	scrapture_sprite.texture = (
		scrapture_definition.overworld_texture
	)


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


func _on_wander_timer_timeout() -> void:
	if not wander_enabled:
		return

	if is_moving:
		return

	var directions: Array[Vector2] = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.ZERO
	]

	var direction: Vector2 = directions.pick_random()

	if direction == Vector2.ZERO:
		return

	var target_position: Vector2 = (
		position + direction * GRID_SIZE
	)

	var max_distance: float = (
		wander_radius_tiles * GRID_SIZE
	)

	if abs(target_position.x - spawn_position.x) > max_distance:
		return

	if abs(target_position.y - spawn_position.y) > max_distance:
		return

	is_moving = true

	var tween: Tween = create_tween()

	tween.tween_property(
		self,
		"position",
		target_position,
		WANDER_MOVE_DURATION
	)

	await tween.finished

	is_moving = false