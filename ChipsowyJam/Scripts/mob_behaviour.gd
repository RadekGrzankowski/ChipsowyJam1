extends "res://Scripts/mob_movement.gd"

@export var mob_health: int = 100
@export var mob_melee_attack: float = 15.0
@export var mob_armor: float = 2.0
@export var health_label: Label3D
var teamName: String

@export var hit_area3D: Area3D

var enemies_to_attack: Array[Node3D]

var detected_enemies_array: Array[Node3D]
var opponent_to_attack: Node3D

func _ready():
	super()
	health_label.text = str(mob_health)

func initialize(name):
	teamName = name
	
func take_damage(amount, attacker):
	mob_health -= amount - mob_armor	
	if mob_health <= 0:
		attacker.change_target(self)
		if teamName == "red":
			Game.red_minions_killed += 1
			Game.blue_gold += 5
		if teamName == "blue":
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
	else:
		if velocity.length() > 0:
			anim_player.play("CharacterArmature|Walk")
		else:
			anim_player.play("CharacterArmature|Idle")
				
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
				navigation_agent.time_horizon_agents = 0.1
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
		enemies_to_attack[0].take_damage(mob_melee_attack, self)
