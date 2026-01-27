extends Resource
class_name MarchingSquaresToolAttributesList


var brush_type : Dictionary = {
	"name": "brush_type",
	"type": "option",
	"label": "Brush Type",
	"options": ["Round", "Square"],
	"default": 0,
}

var size : Dictionary = {
	"name": "size",
	"type": "slider",
	"label": "Size",
	"range": Vector3(1.0, 50.0, 0.5),
	"default": 15.0,
}

var ease_value : Dictionary = {
	"name": "ease_value",
	"type": "slider",
	"label": "Ease Value",
	"range": Vector3(-5.0, 5.0, 0.1),
	"default": -1.0, # No ease
}

var height : Dictionary = {
	"name": "height",
	"type": "slider",
	"label": "Height",
	"range": Vector3(-50.0, 50.0, 0.1),
	"default": 0.0,
}

var strength : Dictionary = {
	"name": "strength",
	"type": "slider",
	"label": "Strength",
	"range": Vector3(0.1, 10.0, 0.1),
	"default": 3.0,
}

var flatten : Dictionary = {
	"name": "flatten",
	"type": "checkbox",
	"label": "Flatten",
	"default": false,
}

var falloff : Dictionary = {
	"name": "falloff",
	"type": "option",
	"label": "Falloff",
	"options": ["None", "Linear", "Smooth", "Sharp", "Plateau", "Terraced"],
	"default": 2, # SMOOTH
}

var falloff_steps : Dictionary = {
	"name": "falloff_steps",
	"type": "slider",
	"label": "Falloff Steps",
	"range": Vector3(2.0, 20.0, 1.0),
	"default": 5.0,
}

var mask_mode : Dictionary = {
	"name": "mask_mode",
	"type": "checkbox",
	"label": "Mask Mode",
	"default": true,
}

var symmetry : Dictionary = {
	"name": "symmetry",
	"type": "multi_checkbox",
	"label": "Symmetry",
	"flags": [
		{"label": "X", "name": "symmetry_x", "default": false},
		{"label": "Z", "name": "symmetry_z", "default": false}
	]
}

var vp_tex_names : MarchingSquaresTextureNames = preload("res://addons/MarchingSquaresTerrain/resources/texture_names.tres")

var material : Dictionary = {
	"name": "material",
	"type": "option",
	"label": "Material",
	"options": vp_tex_names.texture_names,
	"default": 0,
}

var texture_name : Dictionary = {
	"name": "texture_name",
	"type": "text",
	"label": "Texture Name",
	"default": "New name here...",
}

var chunk_management : Dictionary = {
	"name": "chunk_management",
	"type": "chunk",
	"label": "Chunk Management",
}

var terrain_settings : Dictionary = {
	"name": "terrain_settings",
	"type": "terrain",
	"label": "Terrain Settings",
}

""" 
# Example Attribute Entries
	"name": "",
	"type": "",
	"label": "",
	"range": Vector3(1.0, 50.0, 0.5),
	"options": ["Grass", "Sand", "Rock"],
	"default": 10.0,
"""
