extends CharacterBody3D

@export var movement_speed: float = 15.0
@export var rotate_speed: float = 10.0
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _is_travelling_links: bool = false
var _link_end_point: Vector3

var is_attacking: bool = false
var is_chasing: bool = false
var currentTarget: int = 0
var targetArray = []

#context based variables
@export var look_ahead: float = 2.5
@export var num_rays: int = 8
#context arrays
var ray_directions = []
var interest = []
var danger = []
#context direction
var chosen_dir = Vector3.ZERO
	
func _ready():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var random_rotation = 0
		var angle = i * 10
		if i != 9:
			random_rotation = randf_range(-0.005, 0.005)
		ray_directions[i] = Vector3.RIGHT.rotated(Vector3.UP, deg_to_rad(angle) + random_rotation)
	set_movement_target(targetArray[0])
	
func set_interest():
	# Set interest in each slot based on world direction
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var path_direction = position.direction_to(next_path_position)
	for i in num_rays:
		var d = ray_directions[i].rotated(Vector3.UP, rotation.y).dot(path_direction)
		interest[i] = max(0, d)

func choose_direction():
	# Eliminate interest in slots with danger
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	# Choose direction based on remaining interest
	chosen_dir = Vector3.ZERO
	var highest_interest = 0.0
	var direction = 0
	for i in num_rays:
		if interest[i] > highest_interest:
			highest_interest = interest[i]
			direction = i
	chosen_dir = ray_directions[direction] * highest_interest
	chosen_dir = chosen_dir.normalized()
	
func set_danger():
	# Cast rays to find danger directions
	var worldspace = get_world_3d().direct_space_state
	for i in num_rays:
		var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(global_position + Vector3(0,0.5,0),
		global_position + Vector3(0,0.5,0) + ray_directions[i].rotated(Vector3.UP, rotation.y) * look_ahead))
		if result:
			if is_chasing:
				if self.is_in_group("blue_team"):
					if result.collider.is_in_group("blue_team"):
						danger[i] = 1.0
				elif self.is_in_group("red_team"):
					if result.collider.is_in_group("red_team"):
						danger[i] = 1.0
			else:
				danger[i] = 1.0
		else:
			danger[i] = 0.0
	if is_chasing:
		for i in num_rays - 2:
			if danger[i + 1] == 0.0:
				if danger[i] == 1.0 && danger[i+2] == 1.0:
					danger[i+1] = 1.0

func _physics_process(delta):
	if !is_attacking:
		if _is_travelling_links:
			if position.distance_to(_link_end_point) < 0.5:
				look_ahead = 1.5
				_is_travelling_links = false
			var new_velocity: Vector3 = chosen_dir.rotated(Vector3.UP, rotation.y) * movement_speed
			_on_navigation_agent_3d_velocity_computed(new_velocity)
			return
		if navigation_agent.is_navigation_finished() && navigation_agent.target_position == targetArray[currentTarget]:
			if currentTarget < targetArray.size() - 1:
				set_next_target()
			return

		set_interest()
		set_danger()
		choose_direction()

		var new_velocity: Vector3 = chosen_dir.rotated(Vector3.UP, rotation.y) * movement_speed
		# rotates the mob into the direction of movement
		rotation.y = lerp_angle(rotation.y, atan2(-new_velocity.x, -new_velocity.z), delta * rotate_speed)
	
		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_velocity)
		else:
			_on_navigation_agent_3d_velocity_computed(new_velocity)

func set_targets(targets: Array):
	targetArray = targets

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
	
func set_next_target():
	currentTarget = currentTarget + 1
	set_movement_target(targetArray[currentTarget])
	
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if !is_attacking:	
		velocity = safe_velocity
		move_and_slide()



