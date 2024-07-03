extends Node3D

@onready var p1_marker_top: Marker3D = get_node("/root/GameNode/Terrain/Player1_TopSpawner")
@onready var p1_marker_mid: Marker3D = get_node("/root/GameNode/Terrain/Player1_MidSpawner")
@onready var p1_marker_bot: Marker3D = get_node("/root/GameNode/Terrain/Player1_BotSpawner")

@onready var p2_marker_top: Marker3D = get_node("/root/GameNode/Terrain/Player2_TopSpawner")
@onready var p2_marker_mid: Marker3D = get_node("/root/GameNode/Terrain/Player2_MidSpawner")
@onready var p2_marker_bot: Marker3D = get_node("/root/GameNode/Terrain/Player2_BotSpawner")

@onready var p1_marker_top_exit: Marker3D = get_node("/root/GameNode/Terrain/Player1_TopExit")
@onready var p1_marker_mid_exit: Marker3D = get_node("/root/GameNode/Terrain/Player1_MidExit")
@onready var p1_marker_bot_exit: Marker3D = get_node("/root/GameNode/Terrain/Player1_BotExit")

@onready var p2_marker_top_exit: Marker3D = get_node("/root/GameNode/Terrain/Player2_TopExit")
@onready var p2_marker_mid_exit: Marker3D = get_node("/root/GameNode/Terrain/Player2_MidExit")
@onready var p2_marker_bot_exit: Marker3D = get_node("/root/GameNode/Terrain/Player2_BotExit")

@onready var botPath: Marker3D = get_node("/root/GameNode/Terrain/BotPath")
@onready var topPath: Marker3D = get_node("/root/GameNode/Terrain/TopPath")
@onready var midPath: Marker3D = get_node("/root/GameNode/Terrain/MidPath")

@onready var ai_controller: Node = get_node("/root/GameNode/AIController") 

@export var minionScene: PackedScene

@export var minion_models: Array

@onready var waveTimer = $"../WaveTimer"
@onready var startTimer = $"../StartDelayTimer"
@onready var mob_blue_timer = $"../BlueMobTimer"
@onready var mob_red_timer = $"../RedMobTimer"
@onready var blue_nexus_label = $"/root/GameNode/Terrain/NavigationRegion3D/Player1_Nexus/TimerLabel"

var current_blue_count: int = 0
var current_red_count: int = 0

var cardsUI: Node
#amount of blue mobs per lane 
var wave_blue_max_count: int
var blue_top_count: int = 3
var blue_mid_count: int = 3
var blue_bot_count: int = 3
#amount of red mobs per lane 
var wave_red_max_count: int
var red_top_count: int = 3
var red_mid_count: int = 3
var red_bot_count: int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	cardsUI = get_tree().get_first_node_in_group("CardsUI")
	startTimer.wait_time = Game.start_delay_time
	waveTimer.wait_time = Game.wave_time
	startTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !waveTimer.is_stopped():
		blue_nexus_label.set_text("Next wave in: %.fs" % waveTimer.time_left)
	elif !startTimer.is_stopped():
		blue_nexus_label.set_text("Next wave in: %.fs" % startTimer.time_left)

func set_values():
	#check the value for top lane
	var index = 0
	for node in cardsUI.top_lane_nodes:
		if node.is_in_group("locked"):
			break
		index += 1
	blue_top_count = index
	#check the value for mid lane
	index = 0
	for node in cardsUI.middle_lane_nodes:
		if node.is_in_group("locked"):
			break
		index += 1
	blue_mid_count = index
	#check the value for bot lane
	index = 0
	for node in cardsUI.bottom_lane_nodes:
		if node.is_in_group("locked"):
			break
		index += 1
	blue_bot_count = index
	#get the highest value for the wave count
	#INFO getting max counts from AI controller
	red_top_count = ai_controller.top_lane_cards.size()
	red_mid_count = ai_controller.middle_lane_cards.size()
	red_bot_count = ai_controller.bottom_lane_cards.size()
	wave_blue_max_count = max(blue_top_count, blue_mid_count, blue_bot_count)
	wave_red_max_count = max(red_top_count, red_mid_count, red_bot_count)

func spawn_wave():
	set_values()
	waveTimer.start()
	mob_blue_timer.start()
	mob_red_timer.start()
	
func spawn_bot(color: String, path: String, marker: Marker3D):
	var target_positions : Array
	var bot_card
	match path:
		"bot":
			if color == "red":
				target_positions = [p2_marker_bot_exit.position, botPath.position, p1_marker_bot_exit.position, p1_marker_bot.position]
				bot_card = ai_controller.bottom_lane_cards[current_red_count]
			elif color == "blue":
				bot_card = cardsUI.bottom_lane_nodes[current_blue_count].card
				target_positions = [p1_marker_bot_exit.position, botPath.position, p2_marker_bot_exit.position, p2_marker_bot.position]
		"mid":
			if color == "red":
				bot_card = ai_controller.middle_lane_cards[current_red_count]
				target_positions = [p2_marker_mid_exit.position, midPath.position, p1_marker_mid_exit.position, p1_marker_mid.position]
			elif color == "blue":
				bot_card = cardsUI.middle_lane_nodes[current_blue_count].card
				target_positions = [p1_marker_mid_exit.position, midPath.position, p2_marker_mid_exit.position, p2_marker_mid.position]
		"top":
			if color == "red":
				bot_card = ai_controller.top_lane_cards[current_red_count]
				target_positions = [p2_marker_top_exit.position, topPath.position, p1_marker_top_exit.position, p1_marker_top.position]
			elif color == "blue":
				bot_card = cardsUI.top_lane_nodes[current_blue_count].card
				target_positions = [p1_marker_top_exit.position, topPath.position, p2_marker_top_exit.position, p2_marker_top.position]
	var model : PackedScene
	if bot_card != null:
		#model = bot_card.model #WARNING bot_card.model variable is currently empty
		
		#INFO Placeholder model setting based on card race
		#0 - HUMAN_KINGDOM, 1 - OUTLAWS, 2 - MOUNTAIN_CLAN, 3 - FOREST_ORCS, 4 - BLOOD_BROTHERHOOD
		#5 - UNDEAD_PACT, 6 - MOON_ELVES, 7 - SUN_ELVES, 8 - BEAST
		model = minion_models[1]
		match bot_card.race:
			0, 6, 7:
				model = minion_models[7]
			1:
				model = minion_models[6]
			2, 3:
				model = minion_models[1]
			4:
				model = minion_models[5]
			5:
				model = minion_models[3]
			8:
				model = minion_models[2]
	else:
		model = minion_models[0]
	var bot: CharacterBody3D
	if color == "red":
		bot = minionScene.instantiate()
		bot.initialize(bot_card, "red", path, model)
	elif color == "blue":
		bot = minionScene.instantiate()
		bot.initialize(bot_card, "blue", path, model)
		
	bot.position = marker.position
	bot.rotation = marker.rotation
	
	bot.set_targets(target_positions)
	add_child(bot)

func _on_wave_timer_timeout():
	set_values()
	current_blue_count = 0
	current_red_count = 0
	mob_blue_timer.start()
	mob_red_timer.start()


func _on_blue_mob_timer_timeout():
	if current_blue_count < blue_top_count:
		spawn_bot("blue", "top", p1_marker_top)
	if current_blue_count < blue_mid_count:
		spawn_bot("blue", "mid", p1_marker_mid)
	if current_blue_count < blue_bot_count:
		spawn_bot("blue", "bot", p1_marker_bot)

	current_blue_count = current_blue_count + 1
	if current_blue_count == wave_blue_max_count:
		mob_blue_timer.stop()

func _on_red_mob_timer_timeout():
	if current_red_count < red_top_count:
		spawn_bot("red", "top", p2_marker_top)
	if current_red_count < red_mid_count:
		spawn_bot("red", "mid", p2_marker_mid)
	if current_red_count < red_bot_count:
		spawn_bot("red", "bot", p2_marker_bot)
		
	current_red_count = current_red_count + 1
	if current_red_count == wave_red_max_count:
		mob_red_timer.stop()
	
func _on_start_delay_timer_timeout():
	spawn_wave()
