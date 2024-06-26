extends Control

enum zone_type {DECK, SHOP, SELL}
@export var zone: zone_type
enum zone_lane {TOP, MIDDLE, BOTTOM}
@export var lane: zone_lane
var card

func _ready():
	if is_in_group("locked"):
		$PadlockTexture.visible = true
		$LockedLabel.visible = true
		var zone_number: String = name
		$LockedLabel.text = "SLOT " + zone_number.right(1) + " LOCKED"
		$UnlockButton.visible = true
		$UnlockButton.disabled = true

func _unlock(cost: int):
	if Game.player1_gold >= cost:
		Game.player1_gold -= cost
		remove_from_group("locked")
		$PadlockTexture.visible = false
		$LockedLabel.visible = false
		$UnlockButton.visible = false
		for node in get_parent().get_children(false):
			if node.is_in_group("locked"):
				node.get_node("UnlockButton").disabled = false
				break

