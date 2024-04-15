extends Control

@onready var healthBarProgrss = $HealthBar

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().tribe == 'Player':
		healthBarProgrss.tint_progress = Color(0.51, 0.608, 0.306)
	if get_parent().tribe == 'AI':
		healthBarProgrss.tint_progress = Color(0.882, 0.38, 0.373)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
