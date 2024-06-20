extends Node3D

@onready var markerTopRed: Marker3D = get_node("/root/GameNode/Terrain/TopSpawnerRed")
@onready var markerMidRed: Marker3D = get_node("/root/GameNode/Terrain/MidSpawnerRed")
@onready var markerBotRed: Marker3D = get_node("/root/GameNode/Terrain/BotSpawnerRed")
@onready var markerTopBlue: Marker3D = get_node("/root/GameNode/Terrain/TopSpawnerBlue")
@onready var markerMidBlue: Marker3D = get_node("/root/GameNode/Terrain/MidSpawnerBlue")
@onready var markerBotBlue: Marker3D = get_node("/root/GameNode/Terrain/BotSpawnerBlue")

@onready var botPath: Marker3D = get_node("/root/GameNode/Terrain/BotPath")
@onready var topPath: Marker3D = get_node("/root/GameNode/Terrain/TopPath")
@onready var midPath: Marker3D = get_node("/root/GameNode/Terrain/MidPath")

@export var demonScene: PackedScene

@onready var waveTimer = $"../WaveTimer"
@onready var startTimer = $"../StartDelayTimer"
@export var waveTime: int
@onready var mob_blue_timer = $"../BlueMobTimer"
@onready var mob_red_timer = $"../RedMobTimer"
@onready var blue_nexus_label = $"/root/GameNode/Terrain/NexusBlue/TimerLabel"

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
	waveTimer.wait_time = waveTime
	spawn_wave()

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
	wave_blue_max_count = max(blue_top_count, blue_mid_count, blue_bot_count)
	wave_red_max_count = max(red_top_count, red_mid_count, red_bot_count)

func spawn_wave():
	set_values()
	waveTimer.start()
	mob_blue_timer.start()
	mob_red_timer.start()
	
func spawn_bot(color: String, path: String, marker: Marker3D):
	var target_positions : Array
	var bot_card: Control
	match path:
		"bot":
			if color == "red":
				target_positions = [botPath.position, markerBotBlue.position]
			elif color == "blue":
				bot_card = cardsUI.bottom_lane_nodes[current_blue_count].card
				target_positions = [botPath.position, markerBotRed.position]
		"mid":
			if color == "red":
				target_positions = [midPath.position, markerMidBlue.position]
			elif color == "blue":
				bot_card = cardsUI.middle_lane_nodes[current_blue_count].card
				target_positions = [midPath.position, markerMidRed.position]
		"top":
			if color == "red":
				target_positions = [topPath.position, markerTopBlue.position]
			elif color == "blue":
				bot_card = cardsUI.top_lane_nodes[current_blue_count].card
				target_positions = [topPath.position, markerTopRed.position]
		
	var bot: CharacterBody3D
	if color == "red":
		bot = demonScene.instantiate()
		bot.initialize(null, "red", path)
	elif color == "blue":
		bot = demonScene.instantiate()
		bot.initialize(bot_card, "blue", path)
		
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
		spawn_bot("blue", "top", markerTopBlue)
	if current_blue_count < blue_mid_count:
		spawn_bot("blue", "mid", markerMidBlue)
	if current_blue_count < blue_bot_count:
		spawn_bot("blue", "bot", markerBotBlue)

	current_blue_count = current_blue_count + 1
	if current_blue_count == wave_blue_max_count:
		mob_blue_timer.stop()

func _on_red_mob_timer_timeout():
	if current_red_count < red_top_count:
		spawn_bot("red", "top", markerTopRed)
	if current_red_count < red_mid_count:
		spawn_bot("red", "mid", markerMidRed)
	if current_red_count < red_bot_count:
		spawn_bot("red", "bot", markerBotRed)
		
	current_red_count = current_red_count + 1
	if current_red_count == wave_red_max_count:
		mob_red_timer.stop()
	
func _on_start_delay_timer_timeout():
	spawn_wave()



