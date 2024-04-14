extends TextureButton

var chosen = false
var unit

func _ready():
	if unit == 'KnightV1':
		texture_normal = load('res://UnitSprites/16x16 knight 1 v3-icon.png')
	elif unit == 'ArcherV1':
		texture_normal = load('res://UnitSprites/Archer2/Archer2_idle_0.png')
	elif unit == 'ArcherV2':
		texture_normal = load('res://UnitSprites/Archer1/Archer1_idle_0.png')
		
func _on_pressed():
	if !chosen and get_node('../../UnitChosen').get_child_count() < 2:
		chosen = true
		reparent(get_node('../../UnitChosen'))
	else:
		chosen = false
		reparent(get_node('../../UnitPool'))
