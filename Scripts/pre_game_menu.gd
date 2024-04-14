extends Control

@onready var unitPool = $Scale/UnitPool
@onready var unitChosen = $Scale/UnitChosen

var selectedUnitNode = preload("res://Prefabs/selected_unit.tscn")
var unitList = ['KnightV1', 'ArcherV1', 'ArcherV2']

# Called when the node enters the scene tree for the first time.
func _ready():
	for unit in unitList:
		var unitChoice = selectedUnitNode.instantiate()
		unitChoice.unit = unit
		unitPool.add_child(unitChoice)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_game_pressed():
	if unitChosen.get_child_count() > 1:
		for unitSelected in unitChosen.get_children():
			Global.startingUnits.append(unitSelected.unit)
		get_tree().change_scene_to_file("res://MainGameScene/game.tscn")
