extends Node

var player1_gold: int = 100
var player2_gold: int = 100

var player1_barracks_level: int = 0
var player2_barracks_level: int = 0

var start_delay_time: int = 15
var wave_time: int = 45

var player1_minions_top: int
var player1_minions_mid: int
var player1_minions_bot: int
var player2_minions_top: int
var player2_minions_mid: int
var player2_minions_bot: int

var player1_minions_killed: int = 0 
var player2_minions_killed: int = 0

var player1_towers_destroyed: int = 0
var player2_towers_destroyed: int = 0

var winner: String

var additional_player1_minions_dmg: int = 0 
var additional_player2_minions_dmg: int = 0 

var additional_player1_minions_armor: int = 0 
var additional_player2_minions_armor: int = 0 

var additional_player1_top_tower_damage: int = 0
var additional_player1_mid_tower_damage: int = 0
var additional_player1_bot_tower_damage: int = 0

var additional_player2_top_tower_armor: int = 0
var additional_player2_mid_tower_armor: int = 0
var additional_player2_bot_tower_armor: int = 0

#static percentages for different barrack levels and card tiers
var common_0: int = 80
var common_1: int = 65
var common_2: int = 50
var common_3: int = 30
var common_4: int = 20

var rare_0: int = 20
var rare_1: int = 30
var rare_2: int = 35
var rare_3: int = 40
var rare_4: int = 40

var epic_0: int = 0
var epic_1: int = 5
var epic_2: int = 13
var epic_3: int = 25
var epic_4: int = 31

var legendary_0: int = 0
var legendary_1: int = 0
var legendary_2: int = 2
var legendary_3: int = 5
var legendary_4: int = 9

func reset_values():
	player1_minions_killed = 0
	player2_minions_killed = 0
	
	player1_minions_bot = 0
	player1_minions_mid = 0
	player1_minions_top = 0
	
	player2_minions_bot = 0
	player2_minions_mid = 0
	player2_minions_top = 0

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
var player1_color: Color
var player2_color: Color

#static variables for different colors in game
var blue_color: Color = Color.CORNFLOWER_BLUE
var red_color: Color = Color(1, 0.4, 0.3)
var green_color: Color = Color.FOREST_GREEN
var yellow_color: Color = Color.YELLOW
#colors for building teams
var dark_blue_color: Color = Color(0.138, 0.382, 0.586)
var light_blue_color: Color = Color(0.388, 0.702, 0.91)
var dark_red_color: Color = Color(0.824, 0.302, 0.188)
var light_red_color: Color = Color(0.882, 0.435, 0.451)
var dark_green_color: Color = Color(0.188, 0.494, 0.286)
var light_green_color: Color = Color(0.50, 0.91, 0.52)
var dark_yellow_color: Color = Color(0.6, 0.6, 0.1)
var light_yellow_color: Color = Color(0.75, 0.75, 0.1)

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
