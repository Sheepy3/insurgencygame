extends Node
var map_node_scene:PackedScene = preload("res://MapStuff/MapNode/Map_Node.tscn")
var RPU_token_scene:PackedScene = preload("res://MapStuff/RPU_token.tscn")

func build_map(node_data:Dictionary,hex_data:Dictionary,size:int) -> void:
	for key:String in hex_data.keys():
		var new_rpu_token:Node = RPU_token_scene.instantiate()		
		new_rpu_token.position = hex_data[key]
		new_rpu_token.name = "RPU_"+str(key)
		get_parent().add_child(new_rpu_token)
		new_rpu_token.set_owner(get_parent())

	for key:String in node_data.keys():
		var new_dot:Node = map_node_scene.instantiate()
		new_dot.name = key
		new_dot.position = node_data[key]
		new_dot.find_child("Label").text = key
		get_parent().add_child(new_dot)
		new_dot.set_owner(get_parent())
	
	#build overseer dictionary
	var the_nodes:Dictionary
	for key: Node in get_parent().get_children():
		if key.is_in_group("MapNode"):
			var connections:Array
			for value:Node in get_parent().get_children():
				if value.is_in_group("MapNode"):
					if key.position.distance_squared_to(value.position) < 130000 and key.position.distance_squared_to(value.position) != 0:
						connections.append(int(value.name))
			the_nodes[str(key.name)] = connections
	Overseer.The_nodes = the_nodes
	
	
	
	get_parent().initialize(size)
	
	
