extends Node2D

@export var option : PackedScene

@onready var unitListNode = $AllUnits
@onready var roundChange = $GUI/RoundChange
@onready var upgradeSelectionControl = $GUI/UpgradeControlNode
@onready var upgradeSelections = $GUI/UpgradeControlNode/ScaleNode/UpgradeSelections
@onready var activeBonusContainer = $GUI/ActiveBonusContainer

var levels = preload('res://Resources/roundData.tres')

var unitList: Array = [[], []]
var started = false
var upgradeScreenActive = false
var round = 1
var enemiesAdded = false
var draggedUnit
var frozen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	update_bonus_gui()
	var offset = 0
	for unit in Global.startingUnits:
		var unitPrefab : PackedScene = load('res://Prefabs/' + unit + '.tscn')
		var unitInstance = unitPrefab.instantiate()
		unitInstance.global_position = Vector2(390 + offset, 300)
		unitListNode.add_child(unitInstance)
		offset += 20
	round_start()
	for unit in unitListNode.get_children():
		unit.set_selected(false)
		unit.attack_target = unit.get_enemy_target(unitList)
	update_gem_counter()
		
func update_gem_counter():
	$GUI/GemControlNode/GemCounter.text = str(Global.gems)
			
func update_dragged(unit, isDragged):
	if draggedUnit == unit and !isDragged:
		draggedUnit.set_dragged(false)
	elif draggedUnit and draggedUnit != unit:
		if is_instance_valid(draggedUnit):
			draggedUnit.set_dragged(false)
		draggedUnit = unit
		draggedUnit.set_dragged(true)
	else:
		draggedUnit = unit
		draggedUnit.set_dragged(true)
			
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
	if unitList[0].is_empty():
			await get_tree().create_timer(0.5).timeout
			end_game()
			
func update_bonuses():
	Global.unitListPlayer = unitList[0]
	Global.check_race_and_class_bonus()
	update_bonus_gui()
		
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
	update_bonuses()
	refresh_upgrade_menu()

func end_round():
	enemiesAdded = false
	started = false
	roundChange.text = 'Round ' + str(round) + ' Complete!'
	roundChange.visible = true
	$GUI/StartRound.visible = true
	var tween = create_tween()
	tween.tween_property(roundChange, "modulate", Color(1, 1, 1, 0), 3)
	tween.tween_callback(start_next_round_pregame)
	update_bonuses()
	Global.gems += 5
	update_gem_counter()
	
func reset_round_change():
	roundChange.visible = false
	roundChange.modulate = Color(1, 1, 1)
	
func start_next_round_pregame():
	roundChange.modulate = Color(1, 1, 1)
	round += 1
	round_start()

func end_game():
	roundChange.text = 'Game Over!'
	roundChange.visible = true
	$GUI/StartRound.visible = true
	await get_tree().create_timer(2).timeout
	get_tree().quit()
	
func _on_play_pause_toggled(toggled_on):
	if !toggled_on:
		get_tree().paused = false
	else:
		get_tree().paused = true

func _on_speed_toggled(toggled_on):
	if !toggled_on:
		Engine.time_scale = 1
	else:
		Engine.time_scale = 1.25

func _on_start_round_pressed():
	if !upgradeScreenActive and enemiesAdded:
		started = true
		$GUI/StartRound.visible = false
		for unit in unitListNode.get_children():
			unit.set_dragged(false)
			unit.pregameTween.pause()
			unit.set_selected(false)
		update_bonuses()
		
func spawn_enemies():
	for enemy in levels.data['LevelData'][round - 1]:
		var enemyScene = load(enemy['Type'])
		var enemyInstance = enemyScene.instantiate()
		enemyInstance.global_position = Vector2(enemy['X'], enemy['Y'])
		enemyInstance.tribe = 'AI'
		unitListNode.add_child(enemyInstance, true)
	enemiesAdded = true
			
func refresh_upgrade_menu():
	if !frozen:
		for option in upgradeSelections.get_children():
			option.queue_free()
		await get_tree().create_timer(0,1).timeout
		for i in 3:
			var o = option.instantiate()
			upgradeSelections.add_child(o, true)
			
func update_upgrade_menu_on_select(option_selected):
	option_selected.queue_free()
	var o = option.instantiate()
	upgradeSelections.add_child(o, true)
	
func spawn_ally(ally):
	var new_ally = ally.instantiate()
	new_ally.global_position = Vector2(375, 250)
	new_ally.starter_unit = false
	unitListNode.add_child(new_ally, true)
	
func update_bonus_gui():
	for bonus in activeBonusContainer.get_children():
		if Global.activeBonuses.has(bonus.name.split('Bonus', true)[0]):
			bonus.visible = true
		else:
			bonus.visible = false
	
func _on_refresh_shop_pressed():
	if (Global.gems >= 1 and !unitList[0].is_empty()) or Global.gems >= 4:
		Global.gems -= 1
		update_gem_counter()
		refresh_upgrade_menu()
