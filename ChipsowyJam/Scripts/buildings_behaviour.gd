extends Node
@export var building_damage: int = 20
@export var building_armor: int = 5
@export var building_health: int = 500
@export var health_label: Label3D
var teamName: String
var type: int # 1-Tower 2-Nexus

var opponents_array: Array[Node3D]
var opponent_to_attack: Node3D
var attacking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	health_label.text = str(building_health)
	if is_in_group("red_team"):
		teamName = "red"
	elif is_in_group("blue_team"):
		teamName = "blue"
	if is_in_group("nexus"):
		type = 2
	elif is_in_group("tower"):
		type = 1

func take_damage(amount):
	building_health -= amount - building_armor	
	if building_health <= 0:
		queue_free()
	else:
		health_label.text = str(building_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

