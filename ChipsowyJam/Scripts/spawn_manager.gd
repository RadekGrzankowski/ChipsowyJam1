extends Node3D

@export var markerTopRed: Marker3D
@export var markerMidRed: Marker3D
@export var markerBotRed: Marker3D
@export var markerTopBlue: Marker3D
@export var markerMidBlue: Marker3D
@export var markerBotBlue: Marker3D

@export var blueDemon : PackedScene
@export var redDemon : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _spawn_bot(color: String, marker: Marker3D):
	var bot: CharacterBody3D
	if color == "red":
		bot = redDemon.instantiate()
	elif color == "blue":
		bot = blueDemon.instantiate()
		
	bot.position = marker.position
	bot.rotation = marker.position
	
	add_child(bot)
	

func _on_spawnbotblue_pressed():
	_spawn_bot("blue", markerBotBlue)
func _on_spawnmidblue_pressed():
	_spawn_bot("blue", markerMidBlue)
func _on_spawntopblue_pressed():
	_spawn_bot("blue", markerTopBlue)
func _on_spawnbotred_pressed():
	_spawn_bot("red", markerBotRed)
func _on_spawnmidred_pressed():
	_spawn_bot("red", markerMidRed)
func _on_spawntopred_pressed():
	_spawn_bot("red", markerTopRed)
