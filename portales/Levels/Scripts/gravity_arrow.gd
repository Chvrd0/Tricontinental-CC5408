extends Node2D

func _draw():
	# Draw White Arrow (It will inherit the Portal's color, e.g., Blue)
	var color = Color.WHITE
	var from = Vector2(0, 0) # Center
	var to = Vector2(0, 50)  # 50px Down (Local)
	var thick = 6.0
	
	# Shaft
	draw_line(from, to, color, thick)
	
	# Arrowhead
	var head_size = 15
	var direction = (to - from).normalized()
	var perp = Vector2(-direction.y, direction.x)
	var arrow_p1 = to - direction * head_size + perp * head_size * 0.7
	var arrow_p2 = to - direction * head_size - perp * head_size * 0.7
	
	var points = PackedVector2Array([to, arrow_p1, arrow_p2])
	draw_colored_polygon(points, color)

func _process(_delta):
	# Force redraw to ensure it stays visible if things change
	queue_redraw()
