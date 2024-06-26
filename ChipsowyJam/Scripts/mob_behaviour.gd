extends "res://Scripts/mob_movement.gd"
# Generic mobs info
var mob_name: String
@export var mob_health: int = 75
@export var mob_attack: float = 5.0
@export var mob_armor: int = 5.0
@export var attack_speed: float = 1.25
@onready var info_label: Label3D = $InfoLabel
@onready var health_bar: ProgressBar = $HealthBar/SubViewport/Panel/ProgressBar
@onready var health_label: Label = $HealthBar/SubViewport/Panel/ProgressBar/HealthLabel

var teamName: String
enum mob_class {MELEE, RANGED, MAGE}
var minion_class: mob_class
var mob_tier: int = 0
var card_value: float
var path: String
var is_hitted: bool = false

var enemies_to_attack: Array[Node3D]
var detected_enemies_array: Array[Node3D]
var opponent_to_attack: Node3D

# Ranged units variables
@export var projectile_arrow: PackedScene
var path_curve: Curve3D

# Animation variables
var attack_anim: String
var idle_anim: String
var walk_anim: String
var death_anim: String

func _ready():
	super()
	info_label.text = str(mob_name) + " " + str(mob_health) + "HP\n" + \
	str(mob_attack) + "AD " + str(mob_armor) + "ARM"
	health_bar.set_max(mob_health)
	health_bar.set_value(mob_health)
	
	health_label.text = str(mob_health) + "HP"
	var ls = LabelSettings.new()
	#modify label color depending on mob's tier
	match mob_tier:
		0: #COMMON tier
			ls.font_color = Game.common_color
		1: #RARE tier
			ls.font_color = Game.rare_color
		2: #EPIC tier
			ls.font_color = Game.epic_color
		3: #LEGENDARY tier
			ls.font_color = Game.legendary_color
		_: #Default case
			ls.font_color = Game.common_color
	ls.outline_size = 6
	ls.outline_color = Color.BLACK
	ls.font_size = 30
	health_label.label_settings = ls

	var style = health_bar.get_theme_stylebox("fill")
	if teamName == "red":
		style.bg_color = Game.player2_color
		if path == "top":
			Game.player2_minions_top += 1
		elif path == "mid":
			Game.player2_minions_mid += 1
		elif path == "bot":
			Game.player2_minions_bot += 1
	elif teamName == "blue":
		style.bg_color = Game.player1_color
		if path == "top":
			Game.player1_minions_top += 1
		elif path == "mid":
			Game.player1_minions_mid += 1
		elif path == "bot":
			Game.player1_minions_bot += 1
	#INFO setup animations
	for animation: String in anim_player.get_animation_list():
		match animation:
			"Attack":
				attack_anim = "Attack"
			"Idle":
				idle_anim = "Idle"
			"Walk":
				walk_anim = "Walk"
			"Death":
				death_anim = "Death"
	
func initialize(card, team: String, main_path: String, model: PackedScene):
	if card != null:
		mob_name = card.card_name
		minion_class = card.type
		mob_health = card.health
		mob_attack = card.attack_damage
		mob_armor = card.armor
		attack_speed = card.attack_speed
		card_value = card.cost
		mob_tier = card.tier
		$HitArea3D/CollisionShape.shape.radius = card.attack_range
	else:
		mob_name = "Default mob"
		minion_class = mob_class.MELEE
		$HitArea3D/CollisionShape.shape.radius = 1.5
	teamName = team
	path = main_path
	if minion_class == mob_class.RANGED:
		path_curve = $Path3D.curve
		$DetectionArea3D/CollisionShape3D.shape.radius = 8.0
	elif minion_class == mob_class.MAGE:
		path_curve = $Path3D.curve
		$DetectionArea3D/CollisionShape3D.shape.radius = 7.0
	elif minion_class == mob_class.MELEE:
		$DetectionArea3D/CollisionShape3D.shape.radius = 6.0
		
	var _model: Node3D = model.instantiate()
	
	var _rootnode: Node3D = _model.get_node("RootNode")
	if _rootnode.get_parent():
		_rootnode.get_parent().remove_child(_rootnode)
	add_child(_rootnode)
	
	var _anim: AnimationPlayer = _model.get_node("AnimationPlayer")
	if _anim.get_parent():
		_anim.get_parent().remove_child(_anim)
	add_child(_anim)
	_anim.animation_finished.connect(self._on_animation_player_animation_finished)
	
	if team == "red":
		add_to_group("red_team")
		mob_attack += Game.additional_player2_minions_dmg
		mob_armor += Game.additional_player2_minions_armor
	elif team == "blue":
		add_to_group("blue_team")
		mob_attack += Game.additional_player1_minions_dmg
		mob_armor += Game.additional_player1_minions_armor

	
func take_damage(amount, attacker):
	if !is_instance_valid(self) || !is_instance_valid(attacker):
		return
	if amount == null:
		return
	if is_hitted:
		return
	is_hitted = true
	mob_health -= int(amount * get_reduction())
	if mob_health <= 0:
		attacker.change_target(self)
		if teamName == "red":
			if path == "top":
				Game.player2_minions_top -= 1
			elif path == "mid":
				Game.player2_minions_mid -= 1
			elif path == "bot":
				Game.player2_minions_bot -= 1
			Game.player2_minions_killed += 1
			Game.player1_gold += (5 + (card_value * 0.1))
		if teamName == "blue":
			if path == "top":
				Game.player1_minions_top -= 1
			elif path == "mid":
				Game.player1_minions_mid -= 1
			elif path == "bot":
				Game.player1_minions_bot -= 1
			Game.player1_minions_killed += 1
			Game.player2_gold += (5 + (card_value * 0.1))
		is_hitted = false
		queue_free()
	else:
		health_bar.set_value(mob_health)
		health_label.text = str(mob_health) + "HP"
		info_label.text = str(mob_name) + " " + str(mob_health) + "HP\n" + \
		str(mob_attack) + "AD " + str(mob_armor) + "ARM"
		is_hitted = false
	
func get_reduction():
	var armor_divide = 100
	if mob_armor == 0:
		return 1
	elif mob_armor <= 10:
		armor_divide *= 0.6
	elif mob_armor <= 20:
		armor_divide *= 0.5
	elif mob_armor <= 30:
		armor_divide *= 0.4
	elif mob_armor > 30:
		armor_divide *= 0.3
	var damage_reduction = armor_divide / (armor_divide + mob_armor)
	return damage_reduction

func _physics_process(delta):
	super(delta)
	if opponent_to_attack != null:
		# looking at the current enemy to atack
		var look_pos = Vector3(opponent_to_attack.global_position.x, position.y, opponent_to_attack.global_position.z)
		var look_dir = position.direction_to(look_pos)
		rotation.y = lerp_angle(rotation.y, atan2(-look_dir.x, -look_dir.z), delta * rotate_speed)
	if is_attacking:
		anim_player.speed_scale = attack_speed
	else:
		anim_player.speed_scale = 1 

func _process(delta):
	if is_attacking:
		if anim_player.current_animation != attack_anim:
			anim_player.play(attack_anim)
			#spawn an arrow from mob position to enemy when the mob is ranged
			if minion_class == mob_class.RANGED || minion_class == mob_class.MAGE:
				spawn_projectile()
	else:
		if velocity.length() > 0:
			anim_player.play(walk_anim)
		else:
			anim_player.play(idle_anim)
				
func spawn_projectile():
	var projectile: PathFollow3D
	projectile = projectile_arrow.instantiate()
	projectile.target_node = opponent_to_attack
	projectile.position = path_curve.get_point_position(0)
	$Path3D.add_child(projectile)
	projectile.init(teamName)
	
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
		is_chasing = false
		look_ahead = 1.5
		opponent_to_attack = null
		set_movement_target(targetArray[currentTarget])
	else:
		look_ahead = 10
		is_chasing = true
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
	if opponent_to_attack != null:
		#refresh the path curve to the active opponent
		if minion_class == mob_class.RANGED || minion_class == mob_class.MAGE:
			var local_pos: Vector3 = to_local(opponent_to_attack.global_position) + Vector3(0, 1, 0)
			# setting end point of a curve
			path_curve.set_point_position(1, local_pos)
			path_curve.set_point_in(1, Vector3(0, 2, 0))
	if !is_attacking:
		if navigation_agent.is_navigation_finished() && opponent_to_attack == null: return
		if !navigation_agent.is_target_reached():
			if opponent_to_attack != null:
				set_movement_target(opponent_to_attack.global_position)
			else:
				set_movement_target(navigation_agent.target_position)

func _on_hit_area_3d_body_entered(body):
	if teamName == "blue":
		if body.is_in_group("red_team"):
			enemies_to_attack.append(body)
			is_chasing = false
			is_attacking = true
	elif teamName == "red":
		if body.is_in_group("blue_team"):
			enemies_to_attack.append(body)
			is_chasing = false
			is_attacking = true

func _on_hit_area_3d_body_exited(body):
	enemies_to_attack.erase(body)
	if enemies_to_attack.size() == 0:
		is_attacking = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == attack_anim:
		enemies_to_attack[0].take_damage(mob_attack, self)

func _on_navigation_agent_3d_link_reached(details: Dictionary):
	if details.owner.is_in_group("teleport"):
		_link_end_point = details.link_exit_position
		_is_travelling_links = true
		look_ahead = 0.25
