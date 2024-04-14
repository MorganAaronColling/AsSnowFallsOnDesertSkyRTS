extends TextureButton

var unitRNG : int
var unit : PackedScene
@onready var Game = get_node("../../../../")

# Called when the node enters the scene tree for the first time.
func _ready():
	unitRNG = randi_range(0, 1)
	if unitRNG == 1:
		texture_normal = load('res://UnitSprites/16x16 knight 1 v3-icon.png')
		unit = Game.knight1
	else:
		texture_normal = load('res://UnitSprites/Archer2/Archer2_idle_0.png')
		unit = Game.archer2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pressed():
	Game.spawn_ally(unit)
