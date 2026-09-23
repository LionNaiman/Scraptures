extends CharacterBody2D


@export var cell_size: int = 32
@export var grid_columns: int = 10
@export var grid_rows: int = 8
@export var grid_origin: Vector2 = Vector2(160, 120)
@export var blocked_cells: Array[Vector2i] = []
@export var move_duration: float = 0.20
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_moving: bool = false




func _unhandled_input(event: InputEvent) -> void:
	var direction: Vector2 = get_input_direction(event)

	if direction != Vector2.ZERO:
		try_move_one_cell(direction)


func get_input_direction(event: InputEvent) -> Vector2:
	if event.is_action_pressed("move_up"):
		return Vector2.UP

	if event.is_action_pressed("move_down"):
		return Vector2.DOWN

	if event.is_action_pressed("move_left"):
		return Vector2.LEFT

	if event.is_action_pressed("move_right"):
		return Vector2.RIGHT

	return Vector2.ZERO


func try_move_one_cell(direction: Vector2) -> void:
	if is_moving:
		return

	var next_position: Vector2 = position + direction * cell_size

	if (
		is_position_inside_grid(next_position)
		and not is_position_blocked(next_position)
	):
		is_moving = true
		if direction == Vector2.DOWN:
			animated_sprite.play("walk_down")
		var tween: Tween = create_tween()

		tween.tween_property(
			self,
			"position",
			next_position,
			move_duration
		)

		tween.finished.connect(_on_move_finished)

func is_position_inside_grid(target_position: Vector2) -> bool:
	var half_cell: float = cell_size / 2.0

	var minimum_x: float = grid_origin.x + half_cell
	var minimum_y: float = grid_origin.y + half_cell

	var maximum_x: float = grid_origin.x + (grid_columns * cell_size) - half_cell
	var maximum_y: float = grid_origin.y + (grid_rows * cell_size) - half_cell

	return (
		target_position.x >= minimum_x
		and target_position.x <= maximum_x
		and target_position.y >= minimum_y
		and target_position.y <= maximum_y
	)

func world_position_to_grid_cell(
	world_position: Vector2
) -> Vector2i:
	var local_position: Vector2 = world_position - grid_origin

	return Vector2i(
		int(local_position.x / cell_size),
		int(local_position.y / cell_size)
	)

func is_position_blocked(target_position: Vector2) -> bool:
	var target_cell: Vector2i = world_position_to_grid_cell(
		target_position
	)

	return blocked_cells.has(target_cell)

func _on_move_finished() -> void:
	is_moving = false
	animated_sprite.stop()
