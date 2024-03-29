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

@export var blueDemon : PackedScene
@export var redDemon : PackedScene

@onready var waveTimer = $WaveTimer
@onready var mobTimer = $MobTimer

var waveMobCount: int = 6
var currentCount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(waveTimer.time_left)
	pass

func spawn_wave():
	waveTimer.start()
	mobTimer.start()

func spawn_bot(color: String, path: String, marker: Marker3D):
	var bot: CharacterBody3D
	if color == "red":
		bot = redDemon.instantiate()
	elif color == "blue":
		bot = blueDemon.instantiate()
	var target_position : Vector3
	match path:
		"bot":
			target_position = botPath.position
		"mid":
			target_position = midPath.position
		"top":
			target_position = topPath.position
		
	bot.position = marker.position
	bot.rotation = marker.rotation
	add_child(bot)
	
	bot.set_movement_target(target_position)

func _on_spawnbotblue_pressed():
	spawn_bot("blue", "bot", markerBotBlue)
func _on_spawnmidblue_pressed():
	spawn_bot("blue", "mid", markerMidBlue)
func _on_spawntopblue_pressed():
	spawn_bot("blue", "top", markerTopBlue)
func _on_spawnbotred_pressed():
	spawn_bot("red", "bot", markerBotRed)
func _on_spawnmidred_pressed():
	spawn_bot("red", "mid", markerMidRed)
func _on_spawntopred_pressed():
	spawn_bot("red", "top", markerTopRed)


func _on_wave_timer_timeout():
	currentCount = 0
	mobTimer.start()


func _on_mob_timer_timeout():
	currentCount = currentCount + 1
	spawn_bot("blue", "bot", markerBotBlue)
	spawn_bot("blue", "mid", markerMidBlue)
	spawn_bot("blue", "top", markerTopBlue)
	spawn_bot("red", "bot", markerBotRed)
	spawn_bot("red", "mid", markerMidRed)
	spawn_bot("red", "top", markerTopRed)
	if currentCount == waveMobCount:
		mobTimer.stop()


func _on_start_delay_timer_timeout():
	spawn_wave()
