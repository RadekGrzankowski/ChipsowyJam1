extends Node3D

@export var movement_speed = 25
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move(delta)
	pass

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
	# moving the camera
	translate(velocity.normalized() * delta * movement_speed)
	pass
