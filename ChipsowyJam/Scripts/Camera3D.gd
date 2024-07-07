extends Camera3D

@onready var upgrades_ui: CanvasLayer = get_node("/root/GameNode/HUD/GameUIManager/HUD/UpgradesUI")
@onready var cards_ui: Node = get_node("/root/GameNode/CardsUI")
var mouse: Vector2

func _unhandled_input(event):
	if event is InputEventMouse:
		mouse = event.position
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT: 
			select_node()
		

func select_node():
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	if !result:
		return
	var collider = result.collider
	if collider.is_in_group("blue_team"):
		if collider.is_in_group("TopTower") || collider.is_in_group("MidTower") || collider.is_in_group("BotTower") || collider.is_in_group("Nexus"):
			upgrades_ui.visible = true
		elif collider.is_in_group("TopBarrack"):
			cards_ui.lane_value = 0
			cards_ui.change_lane()
		elif collider.is_in_group("MidBarrack"):
			cards_ui.lane_value = 1
			cards_ui.change_lane()
		elif collider.is_in_group("BotBarrack"):
			cards_ui.lane_value = 2
			cards_ui.change_lane()
	elif collider.is_in_group("red_team"):
		print("Clicked on enemy building!")


