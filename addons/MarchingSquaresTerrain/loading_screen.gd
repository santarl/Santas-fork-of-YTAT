extends Control

@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar
@onready var label: Label = $CenterContainer/VBoxContainer/Label

var target_scene_path: String = ""

func _ready():
	target_scene_path = GameManager.next_level_path
	if target_scene_path == "":
		label.text = "Error: No Level"
		push_error("LoadingScreen: No target scene defined in GameManager!")
		return
	
	label.text = "Loading..."
	ResourceLoader.load_threaded_request(target_scene_path)

func _process(_delta):
	if target_scene_path == "":
		return
		
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		var target = progress[0] * 100.0
		progress_bar.value = lerp(progress_bar.value, target, _delta * 10.0)
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		progress_bar.value = 100.0
		set_process(false)
		var scene_resource = ResourceLoader.load_threaded_get(target_scene_path)
		get_tree().change_scene_to_packed(scene_resource)
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		label.text = "Error Loading Level!"
		push_error("Failed to load scene: " + target_scene_path)
		set_process(false)
