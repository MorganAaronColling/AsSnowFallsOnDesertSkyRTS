extends Node

# UnitStats Resource
var unitStats = preload('res://Resources/UnitStats.tres')

@export var orc1 = preload("res://Prefabs/OrcV1.tscn")
@export var orc2 = preload("res://Prefabs/OrcV2.tscn")
@export var orc3 = preload("res://Prefabs/OrcV3.tscn")
@export var orc4 = preload("res://Prefabs/OrcV4.tscn")
@export var knight1 = preload("res://Prefabs/KnightV1.tscn")
@export var knight2 = preload("res://Prefabs/KnightV2.tscn")
@export var knight3 = preload("res://Prefabs/KnightV3.tscn")
@export var knight4 = preload("res://Prefabs/KnightV4.tscn")
@export var archer1 = preload("res://Prefabs/ArcherV1.tscn")
@export var archer2 = preload("res://Prefabs/ArcherV2.tscn")
@export var archer3 = preload("res://Prefabs/ArcherV3.tscn")
@export var archer4 = preload("res://Prefabs/ArcherV4.tscn")
@export var archer5 = preload("res://Prefabs/ArcherV5.tscn")
@export var bandit1 = preload("res://Prefabs/BanditV1.tscn")
@export var bandit2 = preload("res://Prefabs/BanditV2.tscn")
@export var skeleton1 = preload("res://Prefabs/SkeletonV1.tscn")
@export var skeleton2 = preload("res://Prefabs/SkeletonV2.tscn")
@export var skeleton3 = preload("res://Prefabs/SkeletonV3.tscn")
@export var skeleton4 = preload("res://Prefabs/SkeletonV4.tscn")
@export var barbarian1 = preload("res://Prefabs/BarbarianV1.tscn")
@export var barbarian2 = preload("res://Prefabs/BarbarianV2.tscn")
@export var barbarian3 = preload("res://Prefabs/BarbarianV3.tscn")
@export var barbarian4 = preload("res://Prefabs/BarbarianV4.tscn")

var rngToUnit = {
	0 : archer1,
	1 : archer3,
	2 : bandit1,
	3 : barbarian1,
	4 : knight1,
	5 : orc1,
	6 : skeleton1,
	7 : archer2, 
	8 : bandit2, 
	9 : barbarian2, 
	10 : knight2, 
	11 : orc2, 
	12 : skeleton2,
	13 : archer4,
	14 : archer5, 
	15 : barbarian3, 
	16 : knight3, 
	17 : orc3, 
	18 : skeleton3,
	19 : barbarian4,
	20 : knight4,
	21 : orc4, 
	22 : skeleton4
}

var rngToToolTip = {
	0 : 'ArcherV1',
	1 : 'ArcherV3',
	2 : 'BanditV1',
	3 : 'BarbarianV1',
	4 : 'KnightV1',
	5 : 'OrcV1',
	6 : 'SkeletonV1',
	7 : "ArcherV2", 
	8 : "BanditV2", 
	9 : "BarbarianV2", 
	10 : "KnightV2", 
	11 : "OrcV2", 
	12 : "SkeletonV2",
	13 : "ArcherV4", 
	14 : "ArcherV5", 
	15 : "BarbarianV3", 
	16 : "KnightV3", 
	17 : "OrcV3", 
	18 : "SkeletonV3",
	19 : "BarbarianV4", 
	20 : "KnightV4",
	21 : "OrcV4", 
	22 : "SkeletonV4"
}

var rngToSpriteFrames = {
	0 : load('res://SpriteFrames/ArcherV1SpriteFrames.tres'),
	1 : load('res://SpriteFrames/ArcherV3SpriteFrames.tres'),
	2 : load('res://SpriteFrames/BanditV1SpriteFrames.tres'),
	3 : load('res://SpriteFrames/BarbarianV1SpriteFrames.tres'),
	4 : load('res://SpriteFrames/KnightV1SpriteFrames.tres'),
	5 : load('res://SpriteFrames/OrcV1SpriteFrames.tres'),
	6 : load('res://SpriteFrames/SkeletonV1SpriteFrames.tres'),
	7 : load('res://SpriteFrames/ArcherV2SpriteFrames.tres'),
	8 : load('res://SpriteFrames/BanditV2SpriteFrames.tres'),
	9 : load('res://SpriteFrames/BarbarianV2SpriteFrames.tres'),
	10 : load('res://SpriteFrames/KnightV2SpriteFrames.tres'),
	11 : load('res://SpriteFrames/OrcV2SpriteFrames.tres'),
	12 : load('res://SpriteFrames/SkeletonV2SpriteFrames.tres'),
	13 : load('res://SpriteFrames/ArcherV4SpriteFrames.tres'),
	14 : load('res://SpriteFrames/ArcherV5SpriteFrames.tres'),
	15 : load('res://SpriteFrames/BarbarianV3SpriteFrames.tres'),
	16 : load('res://SpriteFrames/KnightV3SpriteFrames.tres'),
	17 : load('res://SpriteFrames/OrcV3SpriteFrames.tres'),
	18 : load('res://SpriteFrames/SkeletonV3SpriteFrames.tres'),
	19 : load('res://SpriteFrames/BarbarianV4SpriteFrames.tres'),
	20 : load('res://SpriteFrames/KnightV4SpriteFrames.tres'),
	21 : load('res://SpriteFrames/OrcV4SpriteFrames.tres'),
	22 : load('res://SpriteFrames/SkeletonV4SpriteFrames.tres')
}

var draggedUnit
var unitListPlayer
var startingUnits = []
var raceList = ['orc', 'feral', 'human', 'undead', 'elven', 'knight']
var classList = ['warrior', 'rogue', 'protector', 'ranger']
var activeBonuses = []
var bonusFunctions = {
	"orc1" : apply_orc_race_bonus_v1,
	'orc2' : apply_orc_race_bonus_v2,
	"undead1" : apply_undead_race_bonus_v1,
	'undead2' : apply_undead_race_bonus_v2,
	"knight1" : apply_knight_race_bonus_v1,
	'knight2' : apply_knight_race_bonus_v2,
	"human1" : apply_human_race_bonus_v1,
	'human2' : apply_human_race_bonus_v2,
	"feral1" : apply_feral_race_bonus_v1,
	'feral2' : apply_feral_race_bonus_v2,
	"elven1" : apply_elven_race_bonus_v1,
	'elven2' : blank,
	"warrior1" : apply_warrior_class_bonus_v1,
	'warrior2' : apply_warrior_class_bonus_v2,
	"rogue1" : apply_rogue_class_bonus_v1,
	'rogue2' : apply_rogue_class_bonus_v2,
	"ranger1" : apply_ranger_class_bonus_v1,
	'ranger2' : apply_ranger_class_bonus_v2,
	"protector1" : apply_protector_class_bonus_v1,
	'protector2' : apply_protector_class_bonus_v2,
	
}
var unitPool = []
var allUnits = []
var star_level = 1
var gems = 100

var healthMultiplier = 1
var attackDamageMultiplier = 1
var animationSpeedMultiplier = 1
var attackSpeedMultiplier = 1
var sturdyAllMultiplier = false
var sturdyKnightMultiplier = false
var arrowBurstElvenMultiplier = false
var lifestealFeralMultiplier = false
var lifestealAllMultiplier = false


func _ready():
	for unit in unitStats.data:
		allUnits.append(unit)
		if unitStats.data[unit].star_rank == 1:
			unitPool.append(unit)
	
func check_race_and_class_bonus():
	reset_multipliers()
	var teamRaceList = []
	var teamClassList = []
	for unit in unitListPlayer:
		teamRaceList.append(unit.race)
		teamClassList.append(unit.unit_class)
	for race in raceList:
		var raceCount = teamRaceList.count(race)
		if raceCount >= 2:
			bonusFunctions[race + '1'].call()
		if raceCount >= 4:
			bonusFunctions[race + '2'].call()
	for unit_class in classList:
		var classCount = teamClassList.count(unit_class)
		if classCount >= 2:
			bonusFunctions[unit_class + '1'].call()
		if classCount >= 4:
			bonusFunctions[unit_class + '2'].call()
	apply_bonuses_to_units()
				
func reset_multipliers():
	activeBonuses = []
	healthMultiplier = 1
	attackDamageMultiplier = 1
	attackSpeedMultiplier = 1
	lifestealAllMultiplier = false
	lifestealFeralMultiplier = false
	sturdyAllMultiplier = false
	sturdyKnightMultiplier = false
	arrowBurstElvenMultiplier = false
			
func apply_orc_race_bonus_v1():
	activeBonuses.append('Orc1')
	healthMultiplier *= 1.10
	
func apply_orc_race_bonus_v2():
	activeBonuses.append('Orc2')
	healthMultiplier *= 1.10
	
func apply_undead_race_bonus_v1():
	activeBonuses.append('Undead1')
	attackDamageMultiplier *= 1.10
	
func apply_undead_race_bonus_v2():
	activeBonuses.append('Undead2')
	attackDamageMultiplier *= 1.25
	
func apply_knight_race_bonus_v1():
	activeBonuses.append('Knight1')
	sturdyKnightMultiplier = true
	
func apply_knight_race_bonus_v2():
	activeBonuses.append('Knight2')
	attackSpeedMultiplier *= 1.25
	
func apply_human_race_bonus_v1():
	activeBonuses.append('Human1')
	attackSpeedMultiplier *= 1.05
	
func apply_human_race_bonus_v2():
	activeBonuses.append('Human2')
	attackSpeedMultiplier *= 1.10
	
func apply_feral_race_bonus_v1():
	activeBonuses.append('Feral1')
	lifestealFeralMultiplier = true
	
func apply_feral_race_bonus_v2():
	activeBonuses.append('Feral2')
	lifestealAllMultiplier = true
	
func apply_elven_race_bonus_v1():
	activeBonuses.append('Elven1')
	arrowBurstElvenMultiplier = true
	
func apply_protector_class_bonus_v1():
	activeBonuses.append('Protector1')
	
func apply_protector_class_bonus_v2():
	activeBonuses.append('Protector2')
	
func apply_rogue_class_bonus_v1():
	activeBonuses.append('Rogue1')
	
func apply_rogue_class_bonus_v2():
	activeBonuses.append('Rogue2')
	
func apply_ranger_class_bonus_v1():
	activeBonuses.append('Ranger1')
	
func apply_ranger_class_bonus_v2():
	activeBonuses.append('Ranger2')
	
func apply_warrior_class_bonus_v1():
	activeBonuses.append('Warrior1')
	
func apply_warrior_class_bonus_v2():
	activeBonuses.append('Warrior2')
	
func blank():
	pass
	
func get_unit_star_rank_multiplier(unit):
	var star_rank_multiplier = 1
	if unit.unit_rank == 1:
		star_rank_multiplier = 1.05
	elif unit.unit_rank == 2:
		star_rank_multiplier = 1.10
	elif unit.unit_rank == 3:
		star_rank_multiplier = 1.15
	return star_rank_multiplier
	
func apply_bonuses_to_units():
	print(activeBonuses)
	for unit in unitListPlayer:
		var data = unit.unitStats.data[unit.name.split('-', true)[0]]
		var star_rank_multiplier = get_unit_star_rank_multiplier(unit)
		unit.max_health = data.max_health * healthMultiplier * star_rank_multiplier
		unit.health = unit.max_health
		unit.attack_damage = data.attack_damage * attackDamageMultiplier * star_rank_multiplier
		unit.update_health_bar()
		unit.attack_speed = data.attack_speed * attackSpeedMultiplier * star_rank_multiplier
		unit.BattlerAnimation.sprite_frames.set_animation_speed('attack', unit.attack_speed * unit.standard_attack_fps)
		if sturdyAllMultiplier or (unit.race == 'knight' and sturdyKnightMultiplier):
			unit.sturdy = true
		else:
			unit.sturdy = data.sturdy
		if lifestealAllMultiplier or (unit.race == 'feral' and lifestealFeralMultiplier):
			unit.lifesteal = true
		else:
			unit.lifesteal = data.lifesteal
		if arrowBurstElvenMultiplier and unit.race == 'elven':
			unit.arrowBurst = true
		else:
			unit.arrowBurst = data.arrowBurst
	
