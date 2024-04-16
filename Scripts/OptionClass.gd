extends TextureButton

var unitRNG : int
var unit : PackedScene
@onready var Game = get_node("../../../../")

# Called when the node enters the scene tree for the first time.
func _ready():
	unitRNG = randi_range(0, 1)
	if unitRNG == 1:
		texture_normal = load('res://UnitSprites/Orc1/Orc1_idle_0.png')
		unit = Game.orc1
	else:
		texture_normal = load('res://UnitSprites/Orc4/Orc4_idle_0.png')
		unit = Game.orc2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pressed():
	Game.spawn_ally(unit)
