extends Node2D

@onready var unitListNode = $AllUnits
var unitList: Array = [[], []]
# Called when the node enters the scene tree for the first time.
func _ready():
	for unit in unitListNode.get_children():
		unit.set_selected(false)
		unit.attack_target = unit.get_enemy_target(unitList)
		print(unit.attack_target)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed('left_click'):
		for unit in unitListNode.get_children():
			unit.set_selected(false)
			
func _on_all_units_child_entered_tree(node):
	if node.tribe == 'AI':
		unitList[1].append(node)
	elif node.tribe == 'Player':
		unitList[0].append(node)
	
func _on_all_units_child_exiting_tree(node):
	if node.tribe == 'AI':
		unitList[1].erase(node)
	elif node.tribe == 'Player':
		unitList[0].erase(node)
