# ScenePathReader.gd
extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1. Get the node that owns this scene (usually the root of the .tscn file)
	var owner_node = get_owner()
	
	if not owner_node:
		print("Error: This node has no owner. Make sure it is saved as part of a scene.")
		return
		
	# 2. Get the full path to the scene file (e.g., "res://scenes/levels/5-2.tscn")
	var scene_path = owner_node.get_scene_file_path()
	
	if scene_path.is_empty():
		print("Error: Scene file path is empty. The scene might not be saved on disk.")
		return
	
	# 3. Extract the file name without the extension (e.g., "5-2")
	# get_file() gives "5-2.tscn"
	var file_name_with_ext = scene_path.get_file() 
	# get_basename() gives "5-2"
	var file_name = file_name_with_ext.get_basename() 
	
	# 4. Split the name by the separator ("-")
	var parts: PackedStringArray = file_name.split("-")
	
	if parts.size() == 2:
		# 5. Parse the World number (first part)
		var parsed_world = parts[0].to_int()
		# 6. Parse the Level number (second part)
		var parsed_level = parts[1].to_int()
				
		# Check for successful parsing (to_int() returns 0 on failure, 
		# but we allow "0" as a valid number)
		if parts[0].is_valid_int() and parts[1].is_valid_int():
			SceneManager.set_internal_world_level(parsed_world, parsed_level)
			print("Successfully parsed scene: World " + str(parsed_world) + ", Level " + str(parsed_level))
		else:
			print("Error: Parts of the scene name ('%s') are not valid numbers." % file_name)
	else:
		print("Error: Scene name ('%s') does not match the required 'World-Level' format (e.g., '1-2')." % file_name)
