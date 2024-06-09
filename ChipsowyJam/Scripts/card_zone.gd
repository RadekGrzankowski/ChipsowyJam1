extends Control

enum zone_type {DECK, SHOP, SELL}
@export var zone: zone_type
@export var card: Control

func set_card(_card: Control):
	card = _card

func _ready():
	if is_in_group("locked"):
		$PadlockTexture.visible = true
		$LockedLabel.visible = true
		var zone_number: String = name
		$LockedLabel.text = "SLOT " + zone_number.right(1) + " LOCKED"
