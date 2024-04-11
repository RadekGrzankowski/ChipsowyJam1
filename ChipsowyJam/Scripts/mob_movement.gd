extends CharacterBody3D

@export var movement_speed: float = 15.0
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_attacking: bool = false
var currentTarget: int = 0
var targetArray = []
	
func _ready():
	set_movement_target(targetArray[0])

func _physics_process(delta):
	if !is_attacking:
		if navigation_agent.is_navigation_finished() && navigation_agent.target_position == targetArray[currentTarget]:
			if currentTarget < targetArray.size() - 1:
				set_next_target()
			return

		var next_path_position: Vector3 = navigation_agent.get_next_path_position()

		var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
		# rotates the mob into the direction of movement
		if velocity.length() > 0:
			look_at(transform.origin + -new_velocity, Vector3.UP)
		
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

func _on_navigation_agent_3d_link_reached(details: Dictionary):
	if details.owner.is_in_group("teleport"):
		self.position = details.link_exit_position

