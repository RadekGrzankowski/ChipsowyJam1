extends Control

enum zone_type {DECK, SHOP}
@export var zone: zone_type
@export var card: Control

func set_card(_card: Control):
	card = _card
