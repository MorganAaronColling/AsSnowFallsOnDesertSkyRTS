extends TextureButton

var unitRNG : int
var unit : PackedScene
@onready var Game = get_node("../../../../")

var rngToUnit = {
	0 : Global.archer1,
	1 : Global.archer3,
	2 : Global.bandit1,
	3 : Global.barbarian1,
	4 : Global.knight1,
	5 : Global.orc1,
	6 : Global.skeleton1
}

var rngToSpriteFrames = {
	0 : load('res://SpriteFrames/ArcherV1SpriteFrames.tres'),
	1 : load('res://SpriteFrames/ArcherV3SpriteFrames.tres'),
	2 : load('res://SpriteFrames/BanditV1SpriteFrames.tres'),
	3 : load('res://SpriteFrames/BarbarianV1SpriteFrames.tres'),
	4 : load('res://SpriteFrames/KnightV1SpriteFrames.tres'),
	5 : load('res://SpriteFrames/OrcV1SpriteFrames.tres'),
	6 : load('res://SpriteFrames/SkeletonV1SpriteFrames.tres')
}

# Called when the node enters the scene tree for the first time.
func _ready():
	unitRNG = randi_range(0, Global.unitPool.size() - 1)
	unit = rngToUnit[unitRNG]
	texture_normal = rngToSpriteFrames[unitRNG].get_frame_texture('idle', 0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pressed():
	Game.spawn_ally(unit)
