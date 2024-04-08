extends Control

signal fow_updated # use it for a minimap or as texture for terrain

@onready var fog_of_war_camera:Camera2D 		= $SubViewportContainer/SubViewport/fow_camera
@onready var fog_of_war_viewport:SubViewport	= $SubViewportContainer/SubViewport 
@onready var fog_of_war_sprite:Sprite2D 		= $SubViewportContainer/SubViewport/fow_texture
@onready var fog_of_war_units_treenode:Node2D 	= $SubViewportContainer/SubViewport/fow_units
@onready var fog_of_war_tick_timer:Timer 		= $fog_tick

var fog_of_war_stored : Array
var fog_of_war_main_image : Image
var fog_of_war_main_texture : ImageTexture
var fog_of_war_viewport_texture : ImageTexture

var map_rect : Rect2

func _ready():
	fog_of_war_sprite.centered = false
	

func new_fog_of_war(new_map_rect:Rect2):
	map_rect = new_map_rect
	
	#set viewport and camera
	fog_of_war_viewport.size = map_rect.size
	(fog_of_war_viewport.get_parent() as SubViewportContainer).size = map_rect.size
	fog_of_war_camera.position = Vector2.ZERO + map_rect.size * 0.50
	
	fog_of_war_main_image = Image.create(
		int(map_rect.size.x),
		int(map_rect.size.y),
		false, Image.FORMAT_RGBA8)
	
	fog_of_war_main_image.fill( Color(0.0,0.0,0.0,1.0))
	update_texture()

func update_texture():
	fog_of_war_main_texture = ImageTexture.create_from_image(fog_of_war_main_image)
	fog_of_war_sprite.set_texture(fog_of_war_main_texture)
	

func fog_of_war_dissolve(dissolve_position:Vector2,dissolbe_image:Image):
	var dissolve_image_used_rect:Rect2 = dissolbe_image.get_used_rect()
	dissolve_position -= dissolve_image_used_rect.size * 0.50 #Offset to the center
	
	var map_pos = map_rect.position + dissolve_position
	fog_of_war_main_image.blend_rect(dissolbe_image, dissolve_image_used_rect, dissolve_position)
	
	update_texture()
	
