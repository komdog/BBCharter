extends Control

const asset_node_prefab = preload("res://prefabs/AssetNode.tscn")

func _ready():
	Events.project_loaded.connect(populate_asset_list)

# Update the list with all assets currently loaded in the project
func populate_asset_list():
	print('Populating Asset List')
	
	#Cleanup Asset List
	for asset_node in $AssetContainer.get_children():
		asset_node.queue_free()
	
	for asset_name in Assets.lib:
		add_asset_to_list(asset_name)
	
	print(Assets.lib)

# Add a loaded asset to the list
func add_asset_to_list(asset_name: String):
	var new_asset_node = asset_node_prefab.instantiate()
	new_asset_node.setup_asset_note(asset_name)
	$AssetContainer.add_child(new_asset_node)
