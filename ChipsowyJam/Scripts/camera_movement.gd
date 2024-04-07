extends Node3D

@export var movement_speed = 25
@export var camera: Camera3D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move(delta)

func _move(delta):
	var velocity = Vector3()
	# camera movement
	if Input.is_action_pressed("move_up"):
		velocity -= transform.basis.z
	if Input.is_action_pressed("move_down"):
		velocity += transform.basis.z
	if Input.is_action_pressed("move_left"):
		velocity -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		velocity += transform.basis.x
	if Input.is_action_just_pressed("mwheelup"):
		position.y -= 1
	if Input.is_action_just_pressed("mwheeldown"):
		position.y += 1
	# moving the camera
	translate(velocity.normalized() * delta * movement_speed)
	#clamping the position to world borders
	var x_pos = clamp(position.x, -50, 50)
	#y_pos value below 10.0 makes the camera clip with the assets
	var y_pos = clamp(position.y, 7.5, 30)
	var z_pos = clamp(position.z, -50, 50)
	var new_pos = Vector3(x_pos,y_pos,z_pos)
	position = new_pos
	
	#rotating the camera based on the normalized height
	var normalized_height = smoothstep(-40.0, 30, position.y)
	camera.rotation_degrees.x = -rad_to_deg(sin(normalized_height))

