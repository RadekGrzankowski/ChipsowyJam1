extends Node

enum type {TOWER, BARRACK, NEXUS}
enum lane {TOP, MIDDLE, BOTTOM}
@export var building_type: type
@export var building_damage: int = 20
@export var building_armor: int = 5
@export var building_health: int = 500
var health_value: int
@export var building_tier: int = 0 #TOWER Tiers: 0-3, BARRACK Tiers: 0-4, NEXUS Tiers: 0-4
@export var building_range: float = 5.0
@export var building_lane: lane
var building_speed: float = 0.5
var teamName: String
#Upgradeable AOE variables
var aoe_enabled: bool = false
var aoe_dmg_percentage: float = 0.0
#Passive gold for Nexus variables
var passive_gold_enabled: bool = false
var passive_gold_amount: float = 0
var passive_gold_time: float = 0
var gold_started: bool = false

@onready var nexus_model: PackedScene = preload("res://Scenes/Assets/Buildings/Models/Nexus.tscn")
@onready var barrack_model: PackedScene = preload("res://Scenes/Assets/Buildings/Models/Barrack.tscn")
@onready var tower_model: PackedScene = preload("res://Scenes/Assets/Buildings/Models/Tower.tscn")

@onready var dark_blue: BaseMaterial3D = preload("res://Materials/DarkBlue.tres")
@onready var light_blue: BaseMaterial3D = preload("res://Materials/LightBlue.tres")
@onready var dark_red: BaseMaterial3D = preload("res://Materials/DarkRed.tres")
@onready var light_red: BaseMaterial3D = preload("res://Materials/LightRed.tres")

@onready var attack_cooldown: Timer = $AttackTimer
@onready var health_bar: ProgressBar = $HealthBar/SubViewport/Panel/ProgressBar
@onready var health_label: Label = $HealthBar/SubViewport/Panel/ProgressBar/HealthLabel
@onready var detection_shape: CollisionShape3D = $DetectionArea/DetectionShape
@onready var stats_label: Label3D = $StatsLabel

@export var projectile_ball: PackedScene

var enemies_to_attack: Array[Node3D]
var enemy_to_attack: Node3D
var is_attacking: bool = false
var can_attack: bool = false
var spawned_projectile: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	health_value = building_health
	health_bar.set_max(building_health)
	health_bar.set_value(health_value)
	health_label.text = str(health_value) + "HP"
	var ls = LabelSettings.new()
	ls.outline_size = 6
	ls.outline_color = Color.BLACK
	ls.font_size = 30
	health_label.label_settings = ls
	var style = health_bar.get_theme_stylebox("fill")
	var _model: StaticBody3D 
	match building_type:
		0: _model = tower_model.instantiate()
		1: _model = barrack_model.instantiate()
		2: _model = nexus_model.instantiate()
	var _mesh: MeshInstance3D = _model.get_node("Mesh")
	if _mesh.get_parent():
		_mesh.get_parent().remove_child(_mesh)
	add_child(_mesh)
	var _collision_shape: CollisionShape3D = _model.get_node("CollisionShape3D")
	if _collision_shape.get_parent():
		_collision_shape.get_parent().remove_child(_collision_shape)
	add_child(_collision_shape)
	if is_in_group("blue_team"):
		style.bg_color = Game.player1_color
		teamName = "blue"
		match building_type:
			0: #TOWER
				_mesh.mesh.surface_set_material(1, dark_blue)
				_mesh.mesh.surface_set_material(3, light_blue)
			1, 2: #BARRACK & NEXUS
				_mesh.mesh.surface_set_material(0, light_blue)
				_mesh.mesh.surface_set_material(1, dark_blue)
	elif is_in_group("red_team"):
		style.bg_color = Game.player2_color
		teamName = "red"
		match building_type:
			0: #TOWER
				_mesh.mesh.surface_set_material(1, dark_red)
				_mesh.mesh.surface_set_material(3, light_red)
			1, 2: #BARRACK & NEXUS
				_mesh.mesh.surface_set_material(0, light_red)
				_mesh.mesh.surface_set_material(1, dark_red)
	detection_shape.shape.radius = building_range
	update_stats()

func update_stats():
	stats_label.text = str(type.keys()[building_type]) + " - " + str(lane.keys()[building_lane]) + "\n" +\
	str(building_damage) + "AD" + " - " + str(building_armor) + "ARMOR" + "\n" +\
	str(building_tier) + " Tier"
	health_bar.set_max(building_health)
	health_bar.set_value(health_value)
	health_label.text = str(health_value) + "HP"
	attack_cooldown.wait_time = building_speed
	detection_shape.shape.radius = building_range

func take_damage(amount, attacker):
	health_value -= int(amount * check_armor())
	if health_value <= 0:
		if building_type == type.TOWER:
			attacker.change_target(self)
			if teamName == "red":
				Game.player2_towers_destroyed += 1
				Game.player1_gold += 50 + (25 * building_tier)
			if teamName == "blue":
				Game.player1_towers_destroyed += 1
				Game.player2_gold += 50 + (25 * building_tier)
			queue_free()
		elif building_type == type.BARRACK:
			attacker.change_target(self)
			if teamName == "red":
				Game.player1_gold += 100 + (25 * building_tier)
			if teamName == "blue":
				Game.player2_gold += 100 + (25 * building_tier)
			queue_free()
		elif building_type == type.NEXUS:
			if teamName == "red":
				Game.winner = "PLAYER 1"
			if teamName == "blue":
				Game.winner = "PLAYER 2"
			get_tree().change_scene_to_file("res://Scenes/Levels/end_scene.tscn")
	else:
		health_label.text = str(health_value) + "HP"
		health_bar.set_value(health_value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if building_type == type.NEXUS:
		if passive_gold_enabled == true:
			if gold_started:
				return
			gold_started = true
			await get_tree().create_timer(passive_gold_time).timeout
			if teamName == "blue":
				Game.player1_gold += passive_gold_amount
			if teamName == "red":
				Game.player2_gold += passive_gold_amount
			gold_started = false
	if building_damage <= 0:
		return
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
	if building_damage <= 0:
		return
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
	return building_damage
