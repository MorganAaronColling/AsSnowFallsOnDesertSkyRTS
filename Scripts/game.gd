extends Node2D

@export var orc1 : PackedScene
@export var orc2 : PackedScene
@export var knight1 : PackedScene

@onready var unitListNode = $AllUnits
@onready var portraitNode = $GUI/Portrait
@onready var roundChange = $GUI/RoundChange
@onready var upgradeSelectionControl = $GUI/UpgradeControlNode

var unitList: Array = [[], []]
var started = false
var upgradeScreenActive = false
var round = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	round_start()
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
	if unitList[1].is_empty():
		await get_tree().create_timer(0.5).timeout
		end_round()
		
func round_start():
	started = false
	roundChange.text = 'Round ' + str(round) + ' Start!'
	roundChange.visible = true
	for unit in unitListNode.get_children():
			unit.reset_health()
	spawn_enemies()
	var tween = create_tween()
	tween.tween_property(roundChange, "modulate", Color(1, 1, 1, 0), 3)
	tween.tween_callback(reset_round_change)

func end_round():
	started = false
	roundChange.text = 'Round ' + str(round) + ' Complete!'
	roundChange.visible = true
	$GUI/StartRound.visible = true
	var tween = create_tween()
	tween.tween_property(roundChange, "modulate", Color(1, 1, 1, 0), 3)
	tween.tween_callback(start_next_round_pregame)
	show_upgrade_menu()
	
func reset_round_change():
	roundChange.visible = false
	roundChange.modulate = Color(1, 1, 1)
	
func start_next_round_pregame():
	roundChange.modulate = Color(1, 1, 1)
	round += 1
	round_start()
	
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

func _on_start_round_pressed():
	if !upgradeScreenActive:
		started = true
		$GUI/StartRound.visible = false
		for unit in unitListNode.get_children():
			unit.set_dragged(false)
			unit.pregameTween.pause()
			unit.set_selected(false)
		
func spawn_enemies():
	var enemy = orc1.instantiate()
	enemy.global_position = Vector2(550, 300)
	unitListNode.add_child(enemy, true)
	var enemy2 = orc1.instantiate()
	enemy2.global_position = Vector2(570, 300)
	unitListNode.add_child(enemy2, true)
	
func show_upgrade_menu():
	upgradeSelectionControl.visible = true
	upgradeScreenActive = true
	
func hide_upgrade_menu():
	upgradeSelectionControl.visible = false
	upgradeScreenActive = false
	
func spawn_ally(ally):
	hide_upgrade_menu()
	var new_ally = ally.instantiate()
	new_ally.global_position = Vector2(375, 250)
	unitListNode.add_child(new_ally, true)
	

