@tool
extends Node3D
# Needs to be kept as a Node3D so that the 3d gizmo works. no 3d functionality is otherwise used, it is delegated to the chunks
class_name MarchingSquaresTerrain

@export var enable_runtime_generation: bool = false # If true, meshes are not saved to disk and are generated on game load.
@export var regenerate_all_chunks: bool = false:
	set(value):
		regenerate_all_chunks = false
		if value:
			force_regenerate_all()

@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var dimensions : Vector3i = Vector3i(33, 32, 33): # Total amount of height values in X and Z direction, and total height range
	set(value):
		dimensions = value
		terrain_material.set_shader_parameter("chunk_size", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var cell_size : Vector2 = Vector2(2, 2) # XZ Unit size of each cell
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var wall_threshold : float = 0.0: # Determines on what part of the terrain's mesh are walls
	set(value):
		wall_threshold = value
		terrain_material.set_shader_parameter("wall_threshold", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("wall_threshold", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var noise_hmap : Noise # used to generate smooth initial heights for more natrual looking terrain. if null, initial terrain will be flat
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var ground_texture : Texture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_terrain_noise.res"):
	set(value):
		ground_texture = value
		terrain_material.set_shader_parameter("vc_tex_rr", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		if ground_texture:
			grass_mat.set_shader_parameter("use_base_color", false)
		else:
			grass_mat.set_shader_parameter("use_base_color", true)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var wall_texture : Texture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_terrain_noise.res"):
	set(value):
		wall_texture = value
		terrain_material.set_shader_parameter("wall_texture", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var ground_color : Color = Color("647851ff"):
	set(value):
		ground_color = value
		terrain_material.set_shader_parameter("ground_albedo", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_base_color", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var wall_color : Color = Color("5e5645ff"):
	set(value):
		wall_color = value
		terrain_material.set_shader_parameter("wall_albedo", value)

# Base grass settings
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var grass_sprite : CompressedTexture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_leaf_sprite.png"):
	set(value):
		grass_sprite = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_texture", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var animation_fps : int = 0:
	set(value):
		animation_fps = clamp(value, 0, 30)
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("fps", clamp(value, 0, 30))
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var grass_subdivisions := 3:
	set(value):
		grass_subdivisions = value
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.multimesh.instance_count = (dimensions.x-1) * (dimensions.z-1) * grass_subdivisions * grass_subdivisions
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var grass_size := Vector2(1.0, 1.0):
	set(value):
		grass_size = value
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.multimesh.mesh.size = value
			chunk.grass_planter.multimesh.mesh.center_offset.y = value.y / 2
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var ridge_threshold: float = 1.0:
	set(value):
		ridge_threshold = value
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var ledge_threshold: float = 0.25:
	set(value):
		ledge_threshold = value
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var use_ridge_texture: bool = false:
	set(value):
		use_ridge_texture = value
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.regenerate_all_cells()

# Vertex painting texture settings
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_2 : Texture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_terrain_noise.res"):
	set(value):
		texture_2 = value
		terrain_material.set_shader_parameter("vc_tex_rg", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		if texture_2:
			grass_mat.set_shader_parameter("use_base_color_2", false)
		else:
			grass_mat.set_shader_parameter("use_base_color_2", true)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_3 : Texture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_terrain_noise.res"):
	set(value):
		texture_3 = value
		terrain_material.set_shader_parameter("vc_tex_rb", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		if texture_3:
			grass_mat.set_shader_parameter("use_base_color_3", false)
		else:
			grass_mat.set_shader_parameter("use_base_color_3", true)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_4 : Texture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_terrain_noise.res"):
	set(value):
		texture_4 = value
		terrain_material.set_shader_parameter("vc_tex_ra", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		if texture_4:
			grass_mat.set_shader_parameter("use_base_color_4", false)
		else:
			grass_mat.set_shader_parameter("use_base_color_4", true)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_5 : Texture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_terrain_noise.res"):
	set(value):
		texture_5 = value
		terrain_material.set_shader_parameter("vc_tex_gr", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		if texture_3:
			grass_mat.set_shader_parameter("use_base_color_5", false)
		else:
			grass_mat.set_shader_parameter("use_base_color_5", true)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_6 : Texture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_terrain_noise.res"):
	set(value):
		texture_6 = value
		terrain_material.set_shader_parameter("vc_tex_gg", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		if texture_6:
			grass_mat.set_shader_parameter("use_base_color_6", false)
		else:
			grass_mat.set_shader_parameter("use_base_color_6", true)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_7 : Texture2D:
	set(value):
		texture_7 = value
		terrain_material.set_shader_parameter("vc_tex_gb", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_8 : Texture2D:
	set(value):
		texture_8 = value
		terrain_material.set_shader_parameter("vc_tex_ga", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_9 : Texture2D:
	set(value):
		texture_9 = value
		terrain_material.set_shader_parameter("vc_tex_br", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_10 : Texture2D:
	set(value):
		texture_10 = value
		terrain_material.set_shader_parameter("vc_tex_bg", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_11 : Texture2D:
	set(value):
		texture_11 = value
		terrain_material.set_shader_parameter("vc_tex_bb", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_12 : Texture2D:
	set(value):
		texture_12 = value
		terrain_material.set_shader_parameter("vc_tex_ba", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_13 : Texture2D:
	set(value):
		texture_13 = value
		terrain_material.set_shader_parameter("vc_tex_ar", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_14 : Texture2D:
	set(value):
		texture_14 = value
		terrain_material.set_shader_parameter("vc_tex_ag", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var texture_15 : Texture2D:
	set(value):
		texture_15 = value
		terrain_material.set_shader_parameter("vc_tex_ab", value)
		for chunk: MarchingSquaresTerrainChunk in chunks.values():
			chunk.grass_planter.regenerate_all_cells()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var tex2_has_grass : bool = true:
	set(value):
		tex2_has_grass = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("use_grass_tex_2", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var tex3_has_grass : bool = true:
	set(value):
		tex3_has_grass = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("use_grass_tex_3", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var tex4_has_grass : bool = true:
	set(value):
		tex4_has_grass = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("use_grass_tex_4", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var tex5_has_grass : bool = true:
	set(value):
		tex5_has_grass = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("use_grass_tex_5", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var tex6_has_grass : bool = true:
	set(value):
		tex6_has_grass = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("use_grass_tex_6", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var grass_sprite_tex_2 : CompressedTexture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_leaf_sprite.png"):
	set(value):
		grass_sprite_tex_2 = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_texture_2", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var grass_sprite_tex_3 : CompressedTexture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_leaf_sprite.png"):
	set(value):
		grass_sprite_tex_3 = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_texture_3", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var grass_sprite_tex_4 : CompressedTexture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_leaf_sprite.png"):
	set(value):
		grass_sprite_tex_4 = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_texture_4", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var grass_sprite_tex_5 : CompressedTexture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_leaf_sprite.png"):
	set(value):
		grass_sprite_tex_5 = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_texture_5", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var grass_sprite_tex_6 : CompressedTexture2D = preload("res://addons/MarchingSquaresTerrain/resources/materials/grass_leaf_sprite.png"):
	set(value):
		grass_sprite_tex_6 = value
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_texture_6", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var ground_color_2 : Color = Color("527b62ff"):
	set(value):
		ground_color_2 = value
		terrain_material.set_shader_parameter("ground_albedo_2", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_color_2", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var ground_color_3 : Color = Color("5f6c4bff"):
	set(value):
		ground_color_3 = value
		terrain_material.set_shader_parameter("ground_albedo_3", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_color_3", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var ground_color_4 : Color = Color("647941ff"):
	set(value):
		ground_color_4 = value
		terrain_material.set_shader_parameter("ground_albedo_4", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_color_4", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var ground_color_5 : Color = Color("4a7e5dff"):
	set(value):
		ground_color_5 = value
		terrain_material.set_shader_parameter("ground_albedo_5", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_color_5", value)
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var ground_color_6 : Color = Color("71725dff"):
	set(value):
		ground_color_6 = value
		terrain_material.set_shader_parameter("ground_albedo_6", value)
		var grass_mat := grass_mesh.material as ShaderMaterial
		grass_mat.set_shader_parameter("grass_color_6", value)

var void_texture := preload("res://addons/MarchingSquaresTerrain/resources/materials/void_texture.tres")
var placeholder_wind_texture := preload("res://addons/MarchingSquaresTerrain/resources/materials/wind_noise_texture.tres") # Change to your own texture

var terrain_material : ShaderMaterial = preload("res://addons/MarchingSquaresTerrain/resources/materials/mst_terrain_shader.tres")
var grass_mesh : QuadMesh = preload("res://addons/MarchingSquaresTerrain/resources/materials/mst_grass_mesh.tres") 

var chunks : Dictionary = {}

signal terrain_generated
signal generation_progress(current: int, total: int)

func _init() -> void:
	if not terrain_material:
		terrain_material = preload("res://addons/MarchingSquaresTerrain/resources/materials/mst_terrain_shader.tres")
	if not grass_mesh:
		grass_mesh = preload("res://addons/MarchingSquaresTerrain/resources/materials/mst_grass_mesh.tres")
	
	print_rich("Welcome to [color=MEDIUM_ORCHID][url=https://www.youtube.com/@yugen_seishin]Yūgen[/url][/color]'s [wave]Marching Squares Terrain Authoring Toolkit[/wave]\nThis plugin is under MIT license")


func _ready() -> void:
	if not Engine.is_editor_hint() and enable_runtime_generation:
		_initialize_runtime()


func _initialize_runtime() -> void:
	_ensure_textures()
	
	# Pause the game to prevent physics/player from falling while generating
	get_tree().paused = true
	
	# Create a temporary loading overlay
	var overlay = CanvasLayer.new()
	overlay.layer = 100 # Ensure it's on top
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS # Update while paused
	
	var color_rect = ColorRect.new()
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.color = Color(0.1, 0.1, 0.1, 1.0)
	overlay.add_child(color_rect)
	
	var center_cont = CenterContainer.new()
	center_cont.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center_cont)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center_cont.add_child(vbox)
	
	var label = Label.new()
	label.text = "Generating Terrain..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	var progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(300, 30)
	progress_bar.show_percentage = true
	vbox.add_child(progress_bar)
	
	add_child(overlay)
	
	chunks.clear()
	var chunks_to_generate = []
	for chunk in get_children():
		if chunk is MarchingSquaresTerrainChunk:
			chunks[chunk.chunk_coords] = chunk
			chunk.terrain_system = self
			chunk.grass_planter = null
			chunks_to_generate.append(chunk)
	
	var total = chunks_to_generate.size()
	var completed_count = 0
	var active_tasks: Dictionary = {} # Map task_id -> chunk
	var pending_index = 0
	var max_concurrent_tasks = OS.get_processor_count() - 1 # Leave 1 core for Main Thread
	if max_concurrent_tasks < 1: max_concurrent_tasks = 1
	
	emit_signal("generation_progress", 0, total)
	# Wait one frame to ensure any loading UI has a chance to appear
	await get_tree().process_frame
	
	var ui_tween: Tween
	
	# Loop until all chunks are completed
	while completed_count < total:
		# 1. Fill up active tasks
		while active_tasks.size() < max_concurrent_tasks and pending_index < total:
			var chunk = chunks_to_generate[pending_index]
			# Initialize data arrays (heightmap, colors, needs_update) on main thread first
			chunk.initialize_terrain(false) 
			var task_id = WorkerThreadPool.add_task(chunk.calculate_mesh_threaded)
			active_tasks[task_id] = chunk
			pending_index += 1
		
		# 2. Poll for completion
		var processed_this_frame = 0
		var max_chunks_per_frame = 1 # Keep this low to ensure high FPS on loading screen
		var tasks_to_remove = []
		
		for task_id in active_tasks.keys():
			if processed_this_frame >= max_chunks_per_frame:
				break
				
			if WorkerThreadPool.is_task_completed(task_id):
				WorkerThreadPool.wait_for_task_completion(task_id) # Clean up task
				var chunk = active_tasks[task_id]
				chunk.apply_generated_mesh() # Apply logic on main thread
				
				completed_count += 1
				processed_this_frame += 1
				tasks_to_remove.append(task_id)
				
				# Update UI smoothly
				var target_value = (float(completed_count) / float(total)) * 100.0
				if ui_tween:
					ui_tween.kill()
				ui_tween = create_tween()
				ui_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Run while paused
				ui_tween.tween_property(progress_bar, "value", target_value, 0.1)
		
		for id in tasks_to_remove:
			active_tasks.erase(id)
		
		emit_signal("generation_progress", completed_count, total)
		await get_tree().process_frame
	
	if ui_tween:
		ui_tween.kill()
	progress_bar.value = 100.0
	
	emit_signal("generation_progress", total, total)
	emit_signal("terrain_generated")
	
	if ui_tween:
		ui_tween.kill()
	progress_bar.value = 100.0
	
	emit_signal("generation_progress", total, total)
	emit_signal("terrain_generated")
	
	# Unpause the game
	get_tree().paused = false
	
	# Fade out overlay
	var tween = create_tween()
	tween.tween_property(overlay, "offset:x", 0.0, 0.5) # Dummy wait
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(overlay.queue_free)


func _enter_tree() -> void:
	call_deferred("_deferred_enter_tree")


func _deferred_enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	
	_ensure_textures()
	
	chunks.clear()
	for chunk in get_children():
		if chunk is MarchingSquaresTerrainChunk:
			chunks[chunk.chunk_coords] = chunk
			chunk.terrain_system = self
			
			chunk.grass_planter = null
			
			chunk.initialize_terrain(true)


func has_chunk(x: int, z: int) -> bool:
	return chunks.has(Vector2i(x, z))


func add_new_chunk(chunk_x: int, chunk_z: int):
	var chunk_coords := Vector2i(chunk_x, chunk_z)
	var new_chunk := MarchingSquaresTerrainChunk.new()
	new_chunk.name = "Chunk "+str(chunk_coords)
	new_chunk.terrain_system = self
	add_chunk(chunk_coords, new_chunk, false)
	
	var chunk_left: MarchingSquaresTerrainChunk = chunks.get(Vector2i(chunk_x-1, chunk_z))
	if chunk_left:
		for z in range(0, dimensions.z):
			new_chunk.height_map[z][0] = chunk_left.height_map[z][dimensions.x - 1]
	
	var chunk_right: MarchingSquaresTerrainChunk = chunks.get(Vector2i(chunk_x+1, chunk_z))
	if chunk_right:
		for z in range(0, dimensions.z):
			chunk_right.height_map[z][dimensions.x - 1] = chunk_right.height_map[z][0]
	
	var chunk_up: MarchingSquaresTerrainChunk = chunks.get(Vector2i(chunk_x, chunk_z-1))
	if chunk_up:
		for x in range(0, dimensions.x):
			new_chunk.height_map[0][x] = chunk_up.height_map[dimensions.z - 1][x]
	
	var chunk_down: MarchingSquaresTerrainChunk = chunks.get(Vector2i(chunk_x, chunk_z+1))
	if chunk_down:
		for x in range(0, dimensions.x):
			new_chunk.height_map[dimensions.z - 1][x] = chunk_down.height_map[0][x]
	
	new_chunk.regenerate_mesh()


func force_regenerate_all() -> void:
	print("Regenerating all chunks...")
	for chunk: MarchingSquaresTerrainChunk in chunks.values():
		if chunk:
			chunk.regenerate_mesh()
	print("All chunks regenerated.")


func remove_chunk(x: int, z: int):
	var chunk_coords := Vector2i(x, z)
	var chunk: MarchingSquaresTerrainChunk = chunks[chunk_coords]
	chunks.erase(chunk)
	chunk.free()


# Remove a chunk but still keep it in memory (so that undo can restore it)
func remove_chunk_from_tree(x: int, z: int):
	var chunk_coords := Vector2i(x, z)
	var chunk: MarchingSquaresTerrainChunk = chunks[chunk_coords]
	chunks.erase(chunk)
	remove_child(chunk)
	chunk.owner = null


func add_chunk(coords: Vector2i, chunk: MarchingSquaresTerrainChunk, regenerate_mesh: bool = true):
	chunks[coords] = chunk
	chunk.terrain_system = self
	chunk.chunk_coords = coords
	
	add_child(chunk)
	
	chunk.global_position = Vector3(
		coords.x * ((dimensions.x - 1) * cell_size.x),
		0,
		coords.y * ((dimensions.z - 1) * cell_size.y)
	)
	
	if Engine.is_editor_hint():
		var editor_interface = Engine.get_singleton('EditorInterface')
		_set_owner_recursive(chunk, editor_interface.get_edited_scene_root())
	else:
		_set_owner_recursive(chunk, get_tree().root)
	chunk.initialize_terrain(regenerate_mesh)
	print_verbose("Added new chunk to terrain system at ", chunk)


func _set_owner_recursive(node: Node, _owner: Node) -> void:
	node.owner = _owner
	for c in node.get_children():
		_set_owner_recursive(c, _owner)


# This function is mainly there to ensure the plugin works on startup in a new project
func _ensure_textures() -> void:
	var grass_mat := grass_mesh.material as ShaderMaterial
	if not grass_mat.get_shader_parameter("use_base_color") and terrain_material.get_shader_parameter("vc_tex_rr") == null:
		terrain_material.set_shader_parameter("vc_tex_rr", ground_texture)
	if grass_mat.get_shader_parameter("use_grass_tex_2") and terrain_material.get_shader_parameter("vc_tex_rg") == null:
		terrain_material.set_shader_parameter("vc_tex_rg", texture_2)
	if grass_mat.get_shader_parameter("use_grass_tex_3") and terrain_material.get_shader_parameter("vc_tex_rb") == null:
		terrain_material.set_shader_parameter("vc_tex_rb", texture_3)
	if grass_mat.get_shader_parameter("use_grass_tex_4") and terrain_material.get_shader_parameter("vc_tex_ra") == null:
		terrain_material.set_shader_parameter("vc_tex_ra", texture_4)
	if grass_mat.get_shader_parameter("use_grass_tex_5") and terrain_material.get_shader_parameter("vc_tex_gr") == null:
		terrain_material.set_shader_parameter("vc_tex_gr", texture_5)
	if grass_mat.get_shader_parameter("use_grass_tex_6") and terrain_material.get_shader_parameter("vc_tex_gg") == null:
		terrain_material.set_shader_parameter("vc_tex_gg", texture_6)
	if grass_mat.get_shader_parameter("wind_texture") == null:
		grass_mat.set_shader_parameter("wind_texture", placeholder_wind_texture)
	if wall_texture and terrain_material.get_shader_parameter("wall_texture") == null:
		terrain_material.set_shader_parameter("wall_texture", wall_texture)
	if grass_sprite and grass_mat.get_shader_parameter("grass_texture") == null:
		grass_mat.set_shader_parameter("grass_texture", grass_sprite)
	if grass_sprite_tex_2 and grass_mat.get_shader_parameter("grass_texture_2") == null:
		grass_mat.set_shader_parameter("grass_texture_2", grass_sprite_tex_2)
	if grass_sprite_tex_3 and grass_mat.get_shader_parameter("grass_texture_3") == null:
		grass_mat.set_shader_parameter("grass_texture_3", grass_sprite_tex_3)
	if grass_sprite_tex_4 and grass_mat.get_shader_parameter("grass_texture_4") == null:
		grass_mat.set_shader_parameter("grass_texture_4", grass_sprite_tex_4)
	if grass_sprite_tex_5 and grass_mat.get_shader_parameter("grass_texture_5") == null:
		grass_mat.set_shader_parameter("grass_texture_5", grass_sprite_tex_5)
	if grass_sprite_tex_6 and grass_mat.get_shader_parameter("grass_texture_6") == null:
		grass_mat.set_shader_parameter("grass_texture_6", grass_sprite_tex_6)
	if terrain_material.get_shader_parameter("vc_tex_aa") == null:
		terrain_material.set_shader_parameter("vc_tex_aa", void_texture)
