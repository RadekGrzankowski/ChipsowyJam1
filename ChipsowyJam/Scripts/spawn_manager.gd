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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _spawn_bot(color: String, path: String, marker: Marker3D):
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
	_spawn_bot("blue", "bot", markerBotBlue)
func _on_spawnmidblue_pressed():
	_spawn_bot("blue", "mid", markerMidBlue)
func _on_spawntopblue_pressed():
	_spawn_bot("blue", "top", markerTopBlue)
func _on_spawnbotred_pressed():
	_spawn_bot("red", "bot", markerBotRed)
func _on_spawnmidred_pressed():
	_spawn_bot("red", "mid", markerMidRed)
func _on_spawntopred_pressed():
	_spawn_bot("red", "top", markerTopRed)
