extends Area2D

# --- Exported Variables ---

# The name of the function (e.g., "reset_state" or "trigger_effect") 
# that will be called on sibling nodes when a body exits this Area2D.
@export var sibling_callback_name: String = "toggle_wall"

# --- Initialization ---

func _ready() -> void:
	# Connect to the body_exited signal, which passes the body (usually a CharacterBody2D) 
	# that just left the Area2D.
	body_exited.connect(_on_body_exited)
	
	if sibling_callback_name.is_empty():
		print("Warning: 'sibling_callback_name' is empty. No functions will be called.")
	else:
		print("Sibling Event Trigger is active. Looking for function: '%s'" % sibling_callback_name)

# --- Signal Handler ---

# This function is automatically called when a PhysicsBody2D or CharacterBody2D exits the area.
func _on_body_exited(body: Node2D) -> void:
	# 1. Get the parent node of this trigger. Siblings are its children.
	var parent_node: Node = get_parent()
	
	if parent_node == null:
		# This is unlikely but guards against the node being scene root/orphaned.
		print("Error: Event Trigger has no parent. Cannot find siblings.")
		return

	# 2. Iterate through all children of the parent (which includes this node and its siblings).
	for sibling in parent_node.get_children():
		# Skip calling the function on itself
		if sibling == self:
			continue 
			
		# 3. Check if the sibling node has the exported function name
		if sibling.has_method(sibling_callback_name):
			# 4. Call the function on the sibling node.
			# Note: We pass the body that exited as an argument, 
			# so the sibling knows *what* exited the zone.
			sibling.call(sibling_callback_name, body)
			# print("Called '%s' on sibling node: %s" % [sibling_callback_name, sibling.name])extends Area2D
