extends StaticBody3D

var start_pos: Vector3
var end_pos: Vector3
var target_node: Node3D
var projectile_speed: float = 5.0

@onready var mesh_instance_blue: GeometryInstance3D = $ProjectileMeshInstanceBlue
@onready var mesh_instance_red: GeometryInstance3D = $ProjectileMeshInstanceRed


# Called when the node enters the scene tree for the first time.
func init(team_name: String):
	if team_name == "red":
		mesh_instance_red.visible = true
	elif team_name == "blue":
		mesh_instance_blue.visible = true
	global_position = start_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(target_node):
		end_pos = target_node.global_position + Vector3(0, 0.6, 0)
		global_position = lerp(global_position, end_pos, delta * projectile_speed)
		if end_pos.distance_to(global_position) < 0.1:
			#print("Hit the opponent")
			queue_free()
	else:
		queue_free()
