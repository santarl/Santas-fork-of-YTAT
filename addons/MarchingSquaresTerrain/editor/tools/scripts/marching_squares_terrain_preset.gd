@tool
extends Resource
class_name MarchingSquaresTerrainPreset


# Preset identification
@export var preset_name: String = "New Preset"

# Wall Configuration (which wall texture slot to use when painting with this preset)
@export_group("Wall")
@export_range(0, 5) var wall_texture_slot: int = 0

# Ground Configuration (which ground texture slot to use when painting with this preset)
@export_group("Ground")
@export_range(0, 15) var ground_texture_slot: int = 0

# Grass Configuration
@export_group("Grass")
@export var has_grass: bool = true
