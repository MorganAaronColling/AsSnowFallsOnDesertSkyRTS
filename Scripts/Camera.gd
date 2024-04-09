extends Camera2D

# Camera speed
var camera_speed = 400

# The amount to zoom in or out each time the mouse wheel is scrolled
var zoom_amount = Vector2(0.05, 0.05)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if zoom.x > 1:
					zoom -= zoom_amount
					position = get_screen_center_position()

			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if zoom.x < 3:
					zoom += zoom_amount
					position = get_screen_center_position()

func _process(delta):
	var distance_from_screen_center = get_global_mouse_position() - get_screen_center_position()
	var direction_from_screen_center = (get_global_mouse_position() - get_screen_center_position()).normalized()
	if distance_from_screen_center.y * zoom.x > 360 and position.y + 360 / zoom.x < limit_bottom:
		position.y += direction_from_screen_center.y * camera_speed * delta
	elif distance_from_screen_center.y * zoom.x < -360 and position.y - 360 / zoom.x > limit_top:
		position.y += direction_from_screen_center.y * camera_speed * delta
	if distance_from_screen_center.x * zoom.x > 640 and position.x + 640 / zoom.x < limit_right:
		position.x += direction_from_screen_center.x * camera_speed * delta
	elif distance_from_screen_center.x * zoom.x < -640 and position.x - 640 / zoom.x > limit_left:
		position.x += direction_from_screen_center.x * camera_speed * delta
