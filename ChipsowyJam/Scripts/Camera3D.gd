extends Camera3D

@onready var top_tower_ui: Control = get_node("/root/GameNode/HUD/GameUIManager/HUD/UpgradeControls/TopTowerUpgrades")
@onready var mid_tower_ui: Control = get_node("/root/GameNode/HUD/GameUIManager/HUD/UpgradeControls/MidTowerUpgrades")
@onready var bot_tower_ui: Control = get_node("/root/GameNode/HUD/GameUIManager/HUD/UpgradeControls/BotTowerUpgrades")
var mouse: Vector2
var mouse_on_UI: bool = false

func _ready():
	top_tower_ui.mouse_entered.connect(self._mouse_entered)
	top_tower_ui.mouse_exited.connect(self._mouse_exited)
	
	mid_tower_ui.mouse_entered.connect(self._mouse_entered)
	mid_tower_ui.mouse_exited.connect(self._mouse_exited)
	
	bot_tower_ui.mouse_entered.connect(self._mouse_entered)
	bot_tower_ui.mouse_exited.connect(self._mouse_exited)
	
	var buttons = get_tree().get_nodes_in_group("button")
	for button in buttons:
		button.mouse_entered.connect(self._mouse_entered)
		button.mouse_exited.connect(self._mouse_exited)

func _input(event):
	if event is InputEventMouse:
		mouse = event.position
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT && !mouse_on_UI:
			select_node()
			
func _mouse_entered():
	mouse_on_UI = true
func _mouse_exited():
	mouse_on_UI = false

func select_node():
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	if !result:
		hide_every_ui()
		return
		
	var collider = result.collider
	#print(result)
	if collider.is_in_group("top_tower"):
		hide_every_ui()
		top_tower_ui.visible = true
	elif collider.is_in_group("mid_tower"):
		hide_every_ui()
		mid_tower_ui.visible = true
	elif collider.is_in_group("bot_tower"):
		hide_every_ui()
		bot_tower_ui.visible = true
	else:
		hide_every_ui()

func hide_every_ui():
	top_tower_ui.visible = false
	mid_tower_ui.visible = false
	bot_tower_ui.visible = false
