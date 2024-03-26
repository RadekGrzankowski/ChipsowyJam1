extends Node3D

@export var markerTopRed: Marker3D
@export var markerMidRed: Marker3D
@export var markerBotRed: Marker3D
@export var markerTopBlue: Marker3D
@export var markerMidBlue: Marker3D
@export var markerBotBlue: Marker3D

@onready var blueDemon = preload("res://Scenes/Assets/Mobs/blue_demon.tscn")
@onready var redDemon = preload("res://Scenes/Assets/Mobs/red_demon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_spawnbotblue_pressed():
	#add_child(blueDemon)
	# cos nie działa :)
	pass # Replace with function body.
