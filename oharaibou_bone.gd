extends Skeleton3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var rootbone: Skeleton3D = get_node("Physical Bone bone").get_parent()
	start_simulation_for_bones(rootbone)
	#print(rootbone.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func start_simulation_for_bones(node):
	#print(node.get_children())
	for child in node.get_children():
		if "cloth" in child.name:
			#print(child.name)
			physical_bones_start_simulation([child.name])
		start_simulation_for_bones(child)
