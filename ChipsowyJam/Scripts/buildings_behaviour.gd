extends Node

enum building_type {TOWER, BARRACK, NEXUS}
@export var type: building_type
@export var building_damage: int = 20
@export var building_armor: int = 5
@export var building_health: int = 500

@onready var attack_cooldown: Timer = $AttackTimer
@onready var health_bar: ProgressBar = $HealthBar/SubViewport/Panel/ProgressBar
@onready var health_label: Label = $HealthBar/SubViewport/Panel/ProgressBar/HealthLabel

@export var projectile_ball: PackedScene
var teamName: String
var lane: String

var enemies_to_attack: Array[Node3D]
var enemy_to_attack: Node3D
var is_attacking: bool = false
var can_attack: bool = false
var spawned_projectile: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.set_max(building_health)
	health_bar.set_value(building_health)
	health_label.text = str(building_health) + "HP"
	var ls = LabelSettings.new()
	ls.outline_size = 6
	ls.outline_color = Color.BLACK
	ls.font_size = 30
	health_label.label_settings = ls
	
	var style = health_bar.get_theme_stylebox("fill")
	if is_in_group("red_team"):
		style.bg_color = Game.red_color
		teamName = "red"
	elif is_in_group("blue_team"):
		style.bg_color = Game.blue_color
		teamName = "blue"
	if type == building_type.TOWER:
		if is_in_group("top_tower"):
			lane = "top"
		elif is_in_group("mid_tower"):
			lane = "mid"
		if is_in_group("bot_tower"):
			lane = "bot"

func take_damage(amount, attacker):
	building_health -= int(amount * check_armor())
	if building_health <= 0:
		if type == building_type.TOWER:
			attacker.change_target(self)
			if teamName == "red":
				Game.red_towers_destroyed += 1
				Game.blue_gold += 50
			if teamName == "blue":
				Game.blue_towers_destroyed += 1
				Game.red_gold += 50
			queue_free()
		elif type == building_type.BARRACK:
			attacker.change_target(self)
			if teamName == "red":
				Game.blue_gold += 100
			if teamName == "blue":
				Game.red_gold += 100
			queue_free()
		elif type == building_type.NEXUS:
			if teamName == "red":
				Game.winner = "BLUE"
			if teamName == "blue":
				Game.winner = "RED"
			get_tree().change_scene_to_file("res://Scenes/Levels/end_scene.tscn")
	else:
		health_label.text = str(building_health) + "HP"
		health_bar.set_value(building_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if type == building_type.TOWER || type == building_type.BARRACK:
		if is_attacking:
			if can_attack:
				enemy_to_attack = closest_target()
				can_attack = false
				attack_cooldown.start()
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
	if enemy_to_attack != null:
		if is_instance_valid(enemy_to_attack) && is_instance_valid(self):
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
