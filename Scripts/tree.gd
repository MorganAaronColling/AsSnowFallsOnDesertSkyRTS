extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(randf_range(0, 1)).timeout
	$AnimatedSprite2D.play('default')
	$AnimatedSprite2DShadow.play('default')
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
