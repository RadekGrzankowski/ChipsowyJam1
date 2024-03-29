extends CharacterBody3D

@export var movement_speed: float = 15.0
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _process(delta):
	if velocity.length() > 0:
		anim_player.play("CharacterArmature|Walk")
	else:
		anim_player.play("CharacterArmature|Idle")

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	look_at(transform.origin + -new_velocity, Vector3.UP)
	# adds the gravity
	if !is_on_floor():
		new_velocity.y -= gravity * delta
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_3d_velocity_computed(new_velocity)
	
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()

