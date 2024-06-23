extends Node

var blue_gold: int = 10000
var red_gold: int = 200

var red_barracks_level: int = 0
var blue_barracks_level: int = 0

var red_minions_top: int
var red_minions_mid: int
var red_minions_bot: int
var blue_minions_top: int
var blue_minions_mid: int
var blue_minions_bot: int

var red_minions_killed: int = 0 
var blue_minions_killed: int = 0

var red_towers_destroyed: int = 0
var blue_towers_destroyed: int = 0

var winner: String

var additional_red_minions_dmg: int = 0 
var additional_blue_minions_dmg: int = 0 

var additional_red_minions_armor: int = 0 
var additional_blue_minions_armor: int = 0 

var additional_blue_top_tower_damage: int = 0
var additional_blue_mid_tower_damage: int = 0
var additional_blue_bot_tower_damage: int = 0

var additional_blue_top_tower_armor: int = 0
var additional_blue_mid_tower_armor: int = 0
var additional_blue_bot_tower_armor: int = 0

#static percentages for different barrack levels and card tiers
var common_0: int = 80
var common_1: int = 60
var common_2: int = 40
var common_3: int = 20
var common_4: int = 10

var rare_0: int = 15
var rare_1: int = 30
var rare_2: int = 40
var rare_3: int = 50
var rare_4: int = 40

var epic_0: int = 4
var epic_1: int = 7
var epic_2: int = 13
var epic_3: int = 18
var epic_4: int = 30

var legendary_0: int = 1
var legendary_1: int = 3
var legendary_2: int = 7
var legendary_3: int = 12
var legendary_4: int = 20

func return_tier(level: int):
	var rand_value = randi_range(0, 100)
	if rand_value <= get("common_"+str(level)):
		return 0
	elif rand_value <= (get("common_"+str(level)) + get("rare_"+str(level))):
		return 1
	elif rand_value <= (get("common_"+str(level)) + get("rare_"+str(level)) + get("epic_"+str(level))):
		return 2
	elif rand_value <= (get("common_"+str(level)) + get("rare_"+str(level)) + get("epic_"+str(level)) + get("legendary_"+str(level))):
		return 3
