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
	6 : skeleton1
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
	"human1" : blank,
	'human2' : blank,
	"feral1" : blank,
	'feral2' : blank,
	"elven1" : blank,
	'elven2' : blank,
	
}
var unitPool = []
var allUnits = []
var star_level = 1

var healthMultiplier = 1
var attackDamageMultiplier = 1
var animationSpeedMultiplier = 1
var sturdyAllMultiplier = false
var sturdyKnightMultiplier = false

func _ready():
	for unit in unitStats.data:
		allUnits.append(unit)
		if unitStats.data[unit].star_rank == 1:
			unitPool.append(unit)
	print(allUnits)
	print(unitPool)
		
	
func check_race_bonus():
	reset_multipliers()
	var teamRaceList = []
	for unit in unitListPlayer:
		teamRaceList.append(unit.race)
	for race in raceList:
		var raceCount = teamRaceList.count(race)
		if raceCount >= 2:
			bonusFunctions[race + '1'].call()
		if raceCount >= 4:
			bonusFunctions[race + '2'].call()
	apply_bonuses_to_units()
				
func reset_multipliers():
	activeBonuses = []
	healthMultiplier = 1
	attackDamageMultiplier = 1
	sturdyAllMultiplier = false
	sturdyKnightMultiplier = false
			
func apply_orc_race_bonus_v1():
	activeBonuses.append('Orc1')
	healthMultiplier *= 1.10
	
func apply_orc_race_bonus_v2():
	activeBonuses.append('Orc2')
	healthMultiplier *= 1.10
	
func apply_undead_race_bonus_v1():
	activeBonuses.append('Undead1')
	attackDamageMultiplier *= 1.25
	
func apply_undead_race_bonus_v2():
	activeBonuses.append('Undead2')
	attackDamageMultiplier *= 1.25
	
func apply_knight_race_bonus_v1():
	activeBonuses.append('Knight1')
	sturdyKnightMultiplier = true
	
func apply_knight_race_bonus_v2():
	activeBonuses.append('Knight2')
	sturdyAllMultiplier = true
	
func blank():
	pass
	
func apply_bonuses_to_units():
	print(activeBonuses)
	for unit in unitListPlayer:
		var data = unit.unitStats.data[unit.name.split('-', true)[0]]
		unit.max_health = data.max_health * healthMultiplier
		unit.health = unit.max_health
		unit.attack_damage = data.attack_damage * attackDamageMultiplier
		unit.update_health_bar()
		if sturdyAllMultiplier or (unit.race == 'knight' and sturdyKnightMultiplier):
			unit.sturdy = true
		else:
			unit.sturdy = data.sturdy
	
