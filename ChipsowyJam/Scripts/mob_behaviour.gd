extends "res://Scripts/mob_movement.gd"

@export var mob_health: int = 100
@export var mob_melee_attack: float = 15.0
@export var mob_armor: float = 2.0
@export var health_label: Label3D
var teamName: String

var opponents_array: Array[Node3D]
var opponent_to_attack: Node3D
var attacking: bool = false

func _ready():
	super()
	health_label.text = str(mob_health)

func initialize(name):
	teamName = name
	
func take_damage(amount):
	mob_health -= amount - mob_armor	
	if mob_health <= 0:
		queue_free()
	else:
		health_label.text = str(mob_health)

func _physics_process(delta):
	super(delta)
	if attacking && opponent_to_attack != null:
		look_at(opponent_to_attack.global_position)
		rotate_object_local(Vector3.UP, PI)

func _process(delta):	
	if velocity.length() > 0:
		anim_player.play("CharacterArmature|Walk")
	else:
		if attacking:
			anim_player.play("CharacterArmature|Weapon")
		else:
			anim_player.play("CharacterArmature|Idle")
	
	if opponents_array.size() > 0:
		if !navigation_agent.target_reached:
			set_target()
			attacking = false
		else:
			if !attacking:
				$AttackTimer.start()
				attacking = true
	
func closest_target():
	var body: Node3D
	var dist: float = INF
	for opponent in opponents_array:
		var new_dist = position.distance_to(opponent.position)
		if new_dist < dist:
			dist = new_dist
			body = opponent
	opponent_to_attack = body
	return body

func set_target():
	if opponents_array.size() == 0:
		opponent_to_attack = null
		set_movement_target(targetArray[currentTarget])
	else:
		var body = closest_target()
		set_movement_target(body.position)

func _on_area_3d_body_entered(body):
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
					set_target()
		elif teamName == "red":
			if body.is_in_group("blue_team"):
				if opponents_array.find(body) == -1:
					opponents_array.append(body)
					set_target()

func _on_area_3d_body_exited(body):
	if opponents_array.size() > 0:
		opponents_array.erase(body)
		set_target()
		

func _on_attack_timer_timeout():
	if opponent_to_attack != null:
		opponent_to_attack.take_damage(mob_melee_attack)
	attacking = false
