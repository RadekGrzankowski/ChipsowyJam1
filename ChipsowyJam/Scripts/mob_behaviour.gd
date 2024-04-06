extends "res://Scripts/mob_movement.gd"

@export var mob_health: int = 100
@export var mob_melee_attack: float = 15.0
@export var mob_armor: float = 2.0
@export var health_label: Label3D
var teamName: String

@export var hit_area3D: Area3D
var detection_raycast: RayCast3D

var opponents_array: Array[Node3D]
var opponent_to_attack: Node3D
#opponent_position will be different from opponent_to_attack position only for detected towers and nexuses
var opponent_position: Vector3 = Vector3.ZERO
var attacking: bool = false

func _ready():
	super()
	detection_raycast = $DetectionRayCast3D
	health_label.text = str(mob_health)

func initialize(name):
	teamName = name
	
func take_damage(amount, attacker):
	mob_health -= amount - mob_armor	
	if mob_health <= 0:
		attacker.change_target(self)
		queue_free()
	else:
		health_label.text = str(mob_health)

func _physics_process(delta):
	super(delta)
	if attacking && opponent_to_attack != null:
		if opponent_position == Vector3.ZERO:
			look_at(opponent_to_attack.global_position)
		else:
			look_at(opponent_position)
		rotate_object_local(Vector3.UP, PI)

func _process(delta):	
	if velocity.length() > 0:
		anim_player.play("CharacterArmature|Walk")
	else:
		if attacking:
			anim_player.play("CharacterArmature|Weapon")
		else:
			anim_player.play("CharacterArmature|Idle")
			
			
func change_target(body: Node3D):
	opponent_to_attack = null
	opponents_array.erase(body)
	set_target()
	
func closest_target():
	var body: Node3D
	var dist: float = INF
	opponent_position = Vector3.ZERO
	for opponent in opponents_array:
		var new_dist = position.distance_to(opponent.global_position)
		if new_dist < dist:
			dist = new_dist
			body = opponent
			if opponent.is_in_group("nexus") || opponent.is_in_group("tower"):
				detection_raycast.look_at(opponent.global_position)
				detection_raycast.rotate_object_local(Vector3.UP, PI)
				# force update of the ray for the updated position of the opponent
				detection_raycast.force_update_transform()
				detection_raycast.force_raycast_update()
				if detection_raycast.is_colliding():			
					print(detection_raycast.get_collision_point())		
					if detection_raycast.get_collider():
						var collider = detection_raycast.get_collider()
						print(collider)
						if collider.is_in_group("tower") || collider.is_in_group("nexus"):
							opponent_position = detection_raycast.get_collision_point()	
							print(opponent_position)
	return body

func set_target():
	if opponents_array.size() == 0:
		opponent_to_attack = null
		set_movement_target(targetArray[currentTarget])
	else:
		opponent_to_attack = closest_target()
		if opponent_position == Vector3.ZERO:
			set_movement_target(opponent_to_attack.global_position)
		else:
			set_movement_target(opponent_position)

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
		elif teamName == "red":
			if body.is_in_group("blue_team"):
				if opponents_array.find(body) == -1:
					opponents_array.append(body)


func _on_area_3d_body_exited(body):
	if opponents_array.size() > 0:
		opponents_array.erase(body)
		if body == opponent_to_attack:
			set_target()
		

func _on_attack_timer_timeout():
	attacking = false


func _on_nav_path_timer_timeout():
	if navigation_agent.is_navigation_finished() && opponent_to_attack == null: return
	if !navigation_agent.is_target_reached():
		if opponent_to_attack != null:
			navigation_agent.time_horizon_agents = 0.1
			if opponent_position == Vector3.ZERO:
				set_movement_target(opponent_to_attack.global_position)
			else:
				set_movement_target(opponent_position)
		else:
			navigation_agent.time_horizon_agents = 1
			set_movement_target(navigation_agent.target_position)
	else:
		if opponent_to_attack:
			if hit_area3D.overlaps_body(opponent_to_attack):
				if !attacking:
					opponent_to_attack.take_damage(mob_melee_attack, self)
					$AttackTimer.start()
					attacking = true
			else:
				set_target()
