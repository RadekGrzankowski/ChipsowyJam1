extends Resource
enum type {TOWER, BARRACK, NEXUS}
@export var building_type: type
@export var building_tier: int
@export var upgrade_cost: int
@export_category("Upgrade values")
@export var bonus_health: int
@export var bonus_damage: float
@export var bonus_armor: int 
@export var bonus_range: float
@export var bonus_speed: float
@export var bonus_aoe: float
@export_category("Nexus upgrades")
@export var passive_gold: float
@export var passive_gold_per_seconds: float

func _init(p_type = 0, p_tier = 0, p_health = 0, p_dmg = 0, p_armor = 0, p_range = 0.0, p_speed = 0.0, p_cost = 0):
	building_type = p_type
	building_tier = p_tier
	bonus_health = p_health
	bonus_damage = p_dmg
	bonus_armor = p_armor
	bonus_range = p_range
	bonus_speed = p_speed
	upgrade_cost = p_cost
