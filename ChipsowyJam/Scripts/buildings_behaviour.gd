extends Node
@export var building_damage: int = 20
@export var building_armor: int = 5
@export var building_health: int = 500
@export var health_label: Label3D
@export var attack_cd: Timer
@export var projectile_ball: PackedScene
var teamName: String
var type: int # 1-Tower 2-Barrack 3-Nexus
var lane: String

var enemies_to_attack: Array[Node3D]
var enemy_to_attack: Node3D
var is_attacking: bool = false
var can_attack: bool = false
var spawned_projectile: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	health_label.text = str(building_health) + "HP"
	if is_in_group("red_team"):
		teamName = "red"
	elif is_in_group("blue_team"):
		teamName = "blue"
	
	if is_in_group("nexus"):
		type = 3
	elif is_in_group("barrack"):
		type = 2
	elif is_in_group("tower"):
		type = 1
		if is_in_group("top_tower"):
			lane = "top"
		elif is_in_group("mid_tower"):
			lane = "mid"
		if is_in_group("bot_tower"):
			lane = "bot"

func take_damage(amount, attacker):
	building_health -= int(amount * check_armor())
	if building_health <= 0:
		if type == 1:
			attacker.change_target(self)
			if teamName == "red":
				Game.red_towers_destroyed += 1
				Game.blue_gold += 20
			if teamName == "blue":
				Game.blue_towers_destroyed += 1
				Game.red_gold += 20
			queue_free()
		elif type == 2:
			attacker.change_target(self)
			if teamName == "red":
				Game.blue_gold += 100
			if teamName == "blue":
				Game.red_gold += 100
			queue_free()
		elif type == 3:
			if teamName == "red":
				Game.winner = "BLUE"
			if teamName == "blue":
				Game.winner = "RED"
			get_tree().change_scene_to_file("res://Scenes/Levels/end_scene.tscn")
	else:
		health_label.text = str(building_health) + "HP"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if type == 1:
		if is_attacking:
			if can_attack:
				enemy_to_attack = closest_target()
				can_attack = false
				attack_cd.start()
				spawn_projectile()
				
func spawn_projectile():
	var projectile: StaticBody3D
	projectile = projectile_ball.instantiate()
	projectile.start_pos = self.global_position + Vector3(0, 1.5, 0)
	projectile.target_node = enemy_to_attack
	add_child(projectile)
	projectile.init(teamName)
	spawned_projectile = projectile

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
	if enemy_to_attack:
		enemy_to_attack.take_damage(check_damage(), self)
	can_attack = true

# This solution does not take into account additional armor. We need to get rid of the global variables and make the building_armor to update with upgrading
func check_armor():
	var armor_divide = 100
	if building_armor == 0:
		return 1
	elif building_armor <= 10:
		armor_divide *= 0.6
	elif building_armor <= 20:
		armor_divide *= 0.5
	elif building_armor <= 30:
		armor_divide *= 0.4
	elif building_armor > 30:
		armor_divide *= 0.3
	var damage_reduction = armor_divide / (armor_divide + building_armor)
	return damage_reduction

# same goes here with the additional dmg global variable. This has to be updated with upgrade
func check_damage():
	if teamName == "blue":
		if lane == "top":
			return building_damage + Game.additional_blue_top_tower_damage
		elif lane == "mid":
			return building_damage + Game.additional_blue_mid_tower_damage
		elif lane == "bot":
			return building_damage + Game.additional_blue_bot_tower_damage
	else:
		return building_damage
