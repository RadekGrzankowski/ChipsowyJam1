extends PathFollow3D

var target_node: Node3D
var projectile_speed: float = 2.5

@onready var mesh_instance_blue: GeometryInstance3D = $StaticBody3D/ProjectileMeshInstanceBlue
@onready var mesh_instance_red: GeometryInstance3D = $StaticBody3D/ProjectileMeshInstanceRed

# Called when the node enters the scene tree for the first time.
func init(team_name: String):
	if team_name == "red":
		mesh_instance_red.visible = true
	elif team_name == "blue":
		mesh_instance_blue.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(target_node):
		progress_ratio += delta * projectile_speed
		if progress_ratio > 0.85:
			queue_free()
	else:
		queue_free()
