extends Node

var draggedUnit
var unitListPlayer
var startingUnits = []
var raceList = ['orc', 'feral', 'human', 'undead', 'elven']
var activeBonuses = []
var bonusFunctions = {
	"orc1" : apply_orc_race_bonus_v1,
	'orc2' : apply_orc_race_bonus_v2
}

var healthMultiplier = 1
var attackDamageMultiplier = 1
var animationSpeedMultiplier = 1
	
func check_race_bonus():
	reset_multipliers()
	var teamRaceList = []
	for unit in unitListPlayer:
		teamRaceList.append(unit.race)
	for race in raceList:
		if race == 'orc':
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
			
func apply_orc_race_bonus_v1():
	activeBonuses.append('Orc1')
	healthMultiplier *= 1.10
	
func apply_orc_race_bonus_v2():
	activeBonuses.append('Orc2')
	healthMultiplier *= 1.10
	
func apply_bonuses_to_units():
	print(activeBonuses)
	for unit in unitListPlayer:
		var data = unit.unitStats.data[unit.name.split('-', true)[0]]
		unit.max_health = data.max_health * healthMultiplier
		unit.health = unit.max_health
		unit.attack_damage = data.attack_damage * attackDamageMultiplier
		unit.update_health_bar()

	
