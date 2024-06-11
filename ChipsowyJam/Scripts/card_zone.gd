extends Control

enum zone_type {DECK, SHOP, SELL}
@export var zone: zone_type
var cards = [] # [0] - top/shop, [1] - middle, [2] - bottom

func _init():
	if zone == zone_type.DECK:
		cards.resize(3)
	elif zone == zone_type.SHOP:
		cards.resize(1)

func _ready():
	if is_in_group("locked"):
		$PadlockTexture.visible = true
		$LockedLabel.visible = true
		var zone_number: String = name
		$LockedLabel.text = "SLOT " + zone_number.right(1) + " LOCKED"
		$UnlockButton.visible = true
		$UnlockButton.disabled = true
		var button = get_tree().get_first_node_in_group("locked")
		button.get_node("UnlockButton").disabled = false

func _unlock(cost: int):
	if Game.blue_gold >= cost:
		Game.blue_gold -= cost
		remove_from_group("locked")
		$PadlockTexture.visible = false
		$LockedLabel.visible = false
		$UnlockButton.visible = false
		if get_tree().get_first_node_in_group("locked"):
			var button = get_tree().get_first_node_in_group("locked")
			button.get_node("UnlockButton").disabled = false

