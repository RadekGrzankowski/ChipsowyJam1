extends Node3D

var world_size:Vector2i = Vector2i(256,256) # in meters / pixels 

@onready var ball_a:MeshInstance3D = $Node3D/Ball
@onready var FOW:Control = $fog_of_war_texture
@onready var worldmap_mesh:MeshInstance3D = $Map

var dissolve_sprite:Texture2D = preload("res://Materials/Textures/fog_of_war.png") 

func _ready() -> void:
	FOW.new_fog_of_war(Rect2(Vector2.ZERO,world_size))
	add_unit_fow(ball_a)
	$Node3D/AnimationPlayer.play("new_animation")
	

func add_unit_fow(fow_node3D:Node3D) ->void:
	# ADD a sprite to fow texture
	var new_sprite:Sprite2D = Sprite2D.new()
	new_sprite.set_texture(get_new_dissolve_image_texture(32))
	FOW.fog_of_war_units_treenode.add_child(new_sprite)
	
	FOW.fog_of_war_units_data[ ball_a.get_instance_id() ] = [ball_a, new_sprite]
	
	
func get_new_dissolve_image_texture(size:int) -> ImageTexture:
	var dissolve_image:Image = (dissolve_sprite.get_image() as Image)
	dissolve_image.resize(size,size)
	return ImageTexture.create_from_image(dissolve_image)
