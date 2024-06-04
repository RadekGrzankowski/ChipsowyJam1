extends CanvasLayer

@onready var ui = $UI

@export var card_scene: PackedScene
@export var orc_cards_array: Array

var ui_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var card: Control = card_scene.instantiate()
	var resource = orc_cards_array[4]
	card.card_resource = resource
	card.position = Vector2(960, 600)
	add_child(card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_shop_button_pressed():
	if ui_open == false:
		ui.position.y += 175
		ui_open = true
	elif ui_open == true:
		ui.position.y -= 175
		ui_open = false
