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
