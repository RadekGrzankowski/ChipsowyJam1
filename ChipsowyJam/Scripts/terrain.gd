extends Node3D

@onready var nav_region = $NavigationRegion3D

func _on_ready():
	nav_region.bake_navigation_mesh(true)
