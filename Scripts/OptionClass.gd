extends Button

var unitRNG : int
var unit : PackedScene
@onready var Game = get_node("../../../../../")
@onready var animatedPortrait = $AnimatedSprite2D

var unitData = Global.unitStats.data
var rngToUnit = Global.rngToUnit
var rngToSpriteFrames = Global.rngToSpriteFrames
var rngToToolTip = Global.rngToToolTip

# Called when the node enters the scene tree for the first time.
func _ready():
	unitRNG = randi_range(0, Global.unitPool.size() - 1)
	unit = rngToUnit[unitRNG]
	animatedPortrait.sprite_frames = rngToSpriteFrames[unitRNG]
	animatedPortrait.play("idle")
	if rngToToolTip[unitRNG] == 'BanditV1' or rngToToolTip[unitRNG] == 'BanditV2':
		animatedPortrait.flip_h = true
	var cleaved = "\nCleaved" if unitData[rngToToolTip[unitRNG]].cleave else ""
	var lifesteal = "\nLifesteal" if unitData[rngToToolTip[unitRNG]].lifesteal else ""
	var sturdy = "\nSturdy" if unitData[rngToToolTip[unitRNG]].sturdy else ""
	var ranged = "\nRanged" if unitData[rngToToolTip[unitRNG]].ranged else ""
	$RaceClass.text = unitData[rngToToolTip[unitRNG]].race + '\n' + unitData[rngToToolTip[unitRNG]].class
	tooltip_text = "Health: " + str(unitData[rngToToolTip[unitRNG]].max_health) + "\nAttack Damage: " + str(unitData[rngToToolTip[unitRNG]].attack_damage) + "\nAttack Speed: " + str(unitData[rngToToolTip[unitRNG]].attack_speed) + "\nAbilities:" + cleaved + sturdy + lifesteal + ranged
	 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pressed():
	if Global.gems >= 3 and !Game.started:
		Global.gems -= 3
		Game.update_gem_counter()
		Game.spawn_ally(unit)
		Game.update_upgrade_menu_on_select(self)
	else:
		pass
