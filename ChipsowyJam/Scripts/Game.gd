extends Node

var blue_gold: int = 100
var red_gold: int = 100

var red_barracks_level: int = 0
var blue_barracks_level: int = 0

var start_delay_time: int = 15
var wave_time: int = 45

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

func reset_values():
	red_minions_killed = 0
	blue_minions_killed = 0
	red_minions_bot = 0
	red_minions_mid = 0
	red_minions_top = 0
	blue_minions_bot = 0
	blue_minions_mid = 0
	blue_minions_top = 0

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

#variables used in code for player and AI bot
var blue_color: Color = Color.CORNFLOWER_BLUE
var red_color: Color = Color(1, 0.4, 0.3)
#static variables for different colors in game
var _blue_color: Color = Color.CORNFLOWER_BLUE
var _red_color: Color = Color(1, 0.4, 0.3)
var green_color: Color = Color.FOREST_GREEN
var yellow_color: Color = Color.YELLOW

#colors for card's tier
var common_color: Color = Color.WHITE
var rare_color: Color = Color(0.50, 0.77, 1)
var epic_color: Color = Color.MEDIUM_ORCHID
var legendary_color: Color = Color.DARK_ORANGE

#background colors for card's races
var human_kingdom_color = Color.ROYAL_BLUE
var outlaws_color = Color.DARK_SLATE_BLUE
var mountain_clan_color = Color(0.243, 0.529, 0.427)
var forest_orcs_color = Color(0.244, 0.473, 0.266)
var blood_brotherhood_color = Color(0.314, 0.1, 0.1)
var undead_pact_color = Color(0.357, 0.11, 0.584)
var moon_elves_color = Color.LEMON_CHIFFON
var sun_elves_color = Color.DARK_ORANGE
var beast_color = Color.DIM_GRAY
