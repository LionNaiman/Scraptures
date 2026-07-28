extends Node2D


@export var columns: int = 10
@export var rows: int = 8
@export var cell_size: int = 32


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_vertical_lines()
	draw_horizontal_lines()


func draw_vertical_lines() -> void:
	for column: int in range(columns + 1):
		var x_position: float = column * cell_size

		draw_line(
			Vector2(x_position, 0),
			Vector2(x_position, rows * cell_size),
				Color.WHITE

		)


func draw_horizontal_lines() -> void:
	for row: int in range(rows + 1):
		var y_position: float = row * cell_size

		draw_line(
			Vector2(0, y_position),
			Vector2(columns * cell_size, y_position),
				Color.WHITE

		)
