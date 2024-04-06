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

func take_damage(amount, attacker):
	building_health -= amount - building_armor	
	if building_health <= 0:
		attacker.change_target(self)
		queue_free()
	else:
		health_label.text = str(building_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func closest_target():
	var body: Node3D
	var dist: float = INF
	for opponent in opponents_array:
		var new_dist = self.position.distance_to(opponent.position)
		if new_dist < dist:
			dist = new_dist
			body = opponent
	opponent_to_attack = body
	return body

func _on_detection_area_body_entered(body):
	if opponents_array.size() == 0:
		if teamName == "blue":
			if body.is_in_group("red_team"):
				opponents_array.append(body)
				set_target()
		elif teamName == "red":
			if body.is_in_group("blue_team"):
				opponents_array.append(body)
				set_target()
	else:
		if teamName == "blue":
			if body.is_in_group("red_team"):
				if opponents_array.find(body) == -1:
					opponents_array.append(body)
		elif teamName == "red":
			if body.is_in_group("blue_team"):
				if opponents_array.find(body) == -1:
					opponents_array.append(body)

func _on_detection_area_body_exited(body):
	1`if opponents_array.size() > 0:
		opponents_array.erase(body)
		set_target()

func set_target():
	if opponents_array.size() == 0:
		opponent_to_attack = null
	else:
		opponent_to_attack = closest_target()
