extends Area2D

var initial_direction: Vector2
var tribe
var attack_target
var damage
var speed = 250
# Called when the node enters the scene tree for the first time.
func _ready():
	if initial_direction.x > 0:
		rotation = Vector2.LEFT.angle_to_point(initial_direction)
	else:
		rotation = Vector2.RIGHT.angle_to_point(initial_direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position += initial_direction * speed * delta

func _on_area_entered(area):
	var parent = area.get_parent()
	if area.is_in_group('Unit') and parent != self and parent.tribe != tribe and parent == attack_target:
		parent.take_damage(damage, true)
		queue_free()

func _on_despawn_timeout():
	queue_free()
