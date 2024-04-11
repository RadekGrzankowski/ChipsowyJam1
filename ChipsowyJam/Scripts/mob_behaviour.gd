extends "res://Scripts/mob_movement.gd"

# Generic mobs info
@export var mob_health: int = 100
@export var mob_attack: float = 15.0
@export var mob_armor: float = 2.0
@export var health_label: Label3D
@export var hit_area3D: Area3D

var teamName: String
var minion_type: String
var path: String

var enemies_to_attack: Array[Node3D]
var detected_enemies_array: Array[Node3D]
var opponent_to_attack: Node3D

# Ranged units variables
@export var projectile_ball: PackedScene
var spawned_projectile: Node3D

func _ready():
	super()
	health_label.text = str(mob_health)
	if teamName == "red":
		if path == "top":
			Game.red_minions_top += 1
		elif path == "mid":
			Game.red_minions_mid += 1
		elif path == "bot":
			Game.red_minions_bot += 1
	elif teamName == "blue":
		if path == "top":
			Game.blue_minions_top += 1
		elif path == "mid":
			Game.blue_minions_mid += 1
		elif path == "bot":
			Game.blue_minions_bot += 1

func initialize(name: String, type: String, main_path: String, additional_dmg: int, additional_armor: int):
	teamName = name
	minion_type = type
	path = main_path
	mob_attack += additional_dmg
	mob_armor += additional_armor
	if name == "red":
		remove_child($RootNode_Blue)
		add_to_group("red_team")
		$RootNode_Red.visible = true
		$RootNode_Red.name = "RootNode"
	elif name == "blue":
		remove_child($RootNode_Red)
		add_to_group("blue_team")
		$RootNode_Blue.visible = true
		$RootNode_Blue.name = "RootNode"
	
func take_damage(amount, attacker):
	#checks if current mob is existing
	if is_instance_valid(self):
		mob_health -= amount - mob_armor	
		if mob_health <= 0:
			attacker.change_target(self)
			if teamName == "red":
				if path == "top":
					Game.red_minions_top -= 1
				elif path == "mid":
					Game.red_minions_mid -= 1
				elif path == "bot":
					Game.red_minions_bot -= 1
				Game.red_minions_killed += 1
				Game.blue_gold += 5
			if teamName == "blue":
				if path == "top":
					Game.blue_minions_top -= 1
				elif path == "mid":
					Game.blue_minions_mid -= 1
				elif path == "bot":
					Game.blue_minions_bot -= 1
				Game.blue_minions_killed += 1
				Game.red_gold += 5
			queue_free()
		else:
			health_label.text = str(mob_health)

func _physics_process(delta):
	super(delta)
	if is_attacking && opponent_to_attack != null:
		var look_pos = Vector3(opponent_to_attack.global_position.x, position.y, opponent_to_attack.global_position.z)
		look_at(look_pos)
		rotate_object_local(Vector3.UP, PI)

func _process(delta):
	if is_attacking:
		if anim_player.current_animation != "CharacterArmature|Weapon":
			anim_player.play("CharacterArmature|Weapon")
			#spawn an arrow from mob position to enemy when the mob is ranged
			if minion_type == "ranged" || minion_type == "mage":
				spawn_projectile()
	else:
		if velocity.length() > 0:
			anim_player.play("CharacterArmature|Walk")
		else:
			anim_player.play("CharacterArmature|Idle")
				
func spawn_projectile():
	var projectile: StaticBody3D
	projectile = projectile_ball.instantiate()
	projectile.start_pos = global_position + Vector3(0, 1.5, 0)
	projectile.target_node = opponent_to_attack
	
	#var path_curve : Curve3D
	#path_curve = $Path3D.curve
	##adding two points of a curve
	#path_curve.clear_points()
	#path_curve.add_point(Vector3.ZERO + Vector3(0, 1.5, 0),Vector3(0, 2, 0), Vector3.ZERO, 0)
	#var localEndPosition = global_position - opponent_to_attack.global_position
	#path_curve.add_point(localEndPosition + Vector3(0,1.5,0),Vector3.ZERO, Vector3(0, 2, 0), 1)
	
	add_child(projectile)
	projectile.init(teamName)
	spawned_projectile = projectile
	
func change_target(body: Node3D):
	opponent_to_attack = null
	detected_enemies_array.erase(body)
	set_target()
	
func closest_target():
	var body: Node3D
	var dist: float = INF
	for opponent in detected_enemies_array:
		var new_dist = position.distance_to(opponent.global_position)
		if new_dist < dist:
			dist = new_dist
			body = opponent
	return body

func set_target():
	if detected_enemies_array.size() == 0:
		opponent_to_attack = null
		set_movement_target(targetArray[currentTarget])
	else:
		opponent_to_attack = closest_target()
		set_movement_target(opponent_to_attack.global_position)


func _on_area_3d_body_entered(body):
	if detected_enemies_array.size() == 0:
		if teamName == "blue":
			if body.is_in_group("red_team"):
				detected_enemies_array.append(body)
				set_target()
		elif teamName == "red":
			if body.is_in_group("blue_team"):
				detected_enemies_array.append(body)
				set_target()
	else:
		if teamName == "blue":
			if body.is_in_group("red_team"):
				if detected_enemies_array.find(body) == -1:
					detected_enemies_array.append(body)
		elif teamName == "red":
			if body.is_in_group("blue_team"):
				if detected_enemies_array.find(body) == -1:
					detected_enemies_array.append(body)

func _on_area_3d_body_exited(body):
	if detected_enemies_array.size() > 0:
		detected_enemies_array.erase(body)
		if body == opponent_to_attack:
			set_target()

func _on_nav_path_timer_timeout():
	if !is_attacking:
		if navigation_agent.is_navigation_finished() && opponent_to_attack == null: return
		if !navigation_agent.is_target_reached():
			if opponent_to_attack != null:
				navigation_agent.time_horizon_agents = 0.25
				set_movement_target(opponent_to_attack.global_position)
			else:
				navigation_agent.time_horizon_agents = 1
				set_movement_target(navigation_agent.target_position)

func _on_hit_area_3d_body_entered(body):
	if teamName == "blue":
		if body.is_in_group("red_team"):
			enemies_to_attack.append(body)
			is_attacking = true
	elif teamName == "red":
		if body.is_in_group("blue_team"):
			enemies_to_attack.append(body)
			is_attacking = true

func _on_hit_area_3d_body_exited(body):
	enemies_to_attack.erase(body)
	if enemies_to_attack.size() == 0:
		is_attacking = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "CharacterArmature|Weapon":
		enemies_to_attack[0].take_damage(mob_attack, self)
