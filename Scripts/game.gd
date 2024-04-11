extends Node2D

@onready var unitListNode = $AllUnits
@onready var portraitNode = $GUI/Portrait

var unitList: Array = [[], []]
# Called when the node enters the scene tree for the first time.
func _ready():
	for unit in unitListNode.get_children():
		unit.set_selected(false)
		unit.attack_target = unit.get_enemy_target(unitList)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed('left_click'):
		for unit in unitListNode.get_children():
			unit.set_selected(false)
			portraitNode.play("default")
				
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


func _on_play_pause_toggled(toggled_on):
	if !toggled_on:
		get_tree().paused = false
	else:
		get_tree().paused = true

func _on_speed_toggled(toggled_on):
	if !toggled_on:
		Engine.time_scale = 1
	else:
		Engine.time_scale = 2
		
func show_options_menu():
	pass
	
func hide_options_menu():
	pass

func _on_portrait_visibility_changed():
	if portraitNode and portraitNode.visible:
		show_options_menu()
	else:
		hide_options_menu()
