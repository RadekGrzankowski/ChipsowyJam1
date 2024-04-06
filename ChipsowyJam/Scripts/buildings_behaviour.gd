extends Node
@export var building_damage: int = 20
@export var building_armor: int = 5
@export var building_health: int = 500
@export var health_label: Label3D
@export var attack_cd: Timer
var teamName: String
var type: int # 1-Tower 2-Nexus

var enemies_to_attack: Array[Node3D]
var enemy_to_attack: Node3D
var is_attacking: bool = false
var can_attack: bool = false

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
	if type == 1:
		if is_attacking:
			if can_attack:
				enemy_to_attack = closest_target()
				enemy_to_attack.take_damage(building_damage, self)
				can_attack = false
				attack_cd.start()
	
func change_target(body: Node3D):
	enemies_to_attack.erase(body)

func closest_target():
	if enemy_to_attack == null:
		var body: Node3D
		var dist: float = INF
		for enemy in enemies_to_attack:
			var new_dist = self.position.distance_to(enemy.position)
			if new_dist < dist:
				dist = new_dist
				body = enemy
		return body
	else:
		return enemy_to_attack

func _on_detection_area_body_entered(body):
	if teamName == "blue":
		if body.is_in_group("red_team"):
			enemies_to_attack.append(body)
			is_attacking = true
	elif teamName == "red":
		if body.is_in_group("blue_team"):
			enemies_to_attack.append(body)
			is_attacking = true

func _on_detection_area_body_exited(body):
		enemies_to_attack.erase(body)
		if enemies_to_attack.size() == 0:
			is_attacking = false
		else:
			enemy_to_attack = closest_target()


func _on_attack_cooldown_timeout():
	can_attack = true
	print("can_attack")
