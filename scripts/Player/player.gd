extends CharacterBody2D


@export var cell_size: int = 32
@export var grid_columns: int = 10
@export var grid_rows: int = 8
@export var grid_origin: Vector2 = Vector2(160, 120)


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
	var next_position: Vector2 = position + direction * cell_size

	if is_position_inside_grid(next_position):
		position = next_position


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
