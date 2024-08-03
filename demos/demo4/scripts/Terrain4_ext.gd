extends "res://demos/demo4/scripts/Terrain4.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ext")
	pass # Replace with function body.

#var chunks = []

#func  _save_chunks(_chunks):
#	print("Saving chunks")
#	chunks = _chunks

func _get_chunk_coords(position, _chunk_size):
	#print(chunk_size)
	var x = position.x / _chunk_size
#	print(x)
	return Vector3(floor(position.x / (_chunk_size)), 0, floor(position.z / _chunk_size))

func _load_chunk(_chunk_coords, _chunks:Dictionary, _chunks_node):
	var chunk = _chunks[_chunk_coords]
	#print("Index: " + str(_chunks. ))
	_chunks_node.add_child(chunk)
	
	#chunks[chunk_coords] = chunk

func _unload_chunk(chunk_coords, _chunks):
	print("Unloading chunk: " + str(chunk_coords))
	var chunk = _chunks.get(chunk_coords)
	#chunk.queue_free()
	_chunks.get_index(0, chunk)
	#_chunks.erase(chunk_coords)

	#chunks[chunk_coords].queue_free()
	#chunks.erase(chunk_coords)

func _load_surrounding_chunks(_surrounding_chunks, _chunks_node):
	#print("Load surrounding chunks")
	#print(_surrounding_chunks)
	for chunk in _surrounding_chunks:
		#var chunk_instance = _surrounding_chunks[chunk_key].instance
		if !chunk.is_inside_tree():
			_chunks_node.add_child(chunk)

func _unload_surrounding_chunks(_surrounding_chunks, _chunks, _chunks_node):
	print("Unload surrounding chunks")
	#print(_surrounding_chunks)
	for chunk in _surrounding_chunks:
		#var chunk_instance = _surrounding_chunks[chunk_key].instance
		if chunk.is_inside_tree():
			_chunks_node.remove_child(chunk)
			_chunks.erase(chunk)
		#print("chunk_instance: " + str(chunk_instance))
		#if chunk_instance != null:
			#print(chunk_instance.name)
		#if chunk_instance != null:

			#print(chunk_instance)
			#if !_surrounding_chunks.has(chunk_key) && chunk_instance.is_inside_tree():
				#print("Unloading chunk: " + str(chunk_key))
				#_chunks_node.remove_child(chunk_instance)
				#_chunks.erase(chunk_key)

			
	#var chunks_node = get_node_or_null("Chunks") #Chunks

func load_initial_chunks(_player_chunk_pos, load_radius, _chunks:Dictionary, _chunks_node):
	print("load_initial_chunks: " + str(load_radius))
	for x in range(-load_radius, load_radius):
		for z in range(-load_radius, load_radius):
			var _chunk_coords = Vector3(_player_chunk_pos.x + x, 0,_player_chunk_pos.z + z)
			if _chunks.has(_chunk_coords):
				print(str(_chunk_coords) + ": " + str(_chunks[_chunk_coords]))
			if _chunks.has(_chunk_coords) && _chunks[_chunk_coords] != null:
				print("Loading chunk: " + str(_chunk_coords))
				#print(_chunks[_chunk_coords])
				_load_chunk(_chunk_coords, _chunks, _chunks_node)
			#else :
				#_unload_chunk(Vector3(x, 0, z), _chunks)
				#_chunks[Vector3(x, 0, y)] = null



func _calculate_normal_map(_heightmap):
	#print("Calculating normal map")
	var normal_map_data = []
	var height = chunk_size
	var width = chunk_size

	for y in range(height):
		for x in range(width):
			var x_l = _heightmap[y * width + (x - 1)] if x > 0 else _heightmap[y * width + x]
			var x_r = _heightmap[y * width + (x + 1)] if x < width - 1 else _heightmap[y * width + x]
			var y_u = _heightmap[(y - 1) * width + x] if y > 0 else _heightmap[y * width + x]
			var y_d = _heightmap[(y + 1) * width + x] if y < height - 1 else _heightmap[y * width + x]

			var tangent = Vector3(2.0, (x_r - x_l) * 0.5, 0.0)
			var bitangent = Vector3(0.0, (y_d - y_u) * 0.5, 2.0)

			var normal = tangent.cross(bitangent)
			normal = normal.normalized()
			normal_map_data.append(normal)

	return normal_map_data

func _save_heightmap_and_normal_map(heightmap, normalmap): #chunk_size, _heightmap, _normalmap, _height_map_path, _normal_map_path
	print("Saving heightmap and normal map")
	var heightmap_image = Image.create(chunk_size, chunk_size, false, Image.FORMAT_L8)
	#heightmap_image.create(chunk_size, chunk_size, false, Image.FORMAT_R8)

	var normal_map_image = Image.create(chunk_size, chunk_size, false, Image.FORMAT_RGBA8)
	#normal_map_image.create(chunk_size, chunk_size, false, Image.FORMAT_RGBA8)

	var min_height = heightmap.min()
	var max_height = heightmap.max()

	for y in range(chunk_size):
		for x in range(chunk_size):
			var height = heightmap[y * chunk_size + x]
			var normalized_height = (height - min_height) / (max_height - min_height)  # Normalize height
			var normal = normalmap[y * chunk_size + x]
			
			var normalized_color = Color(normalized_height, normalized_height, normalized_height)
			heightmap_image.set_pixel(x, y, normalized_color)

			var normal_color = Color(normal.x, normal.y, normal.z, 1.0)
			normal_map_image.set_pixel(x, y, normal_color)

	heightmap_image.save_png(height_map_path)
	normal_map_image.save_png(normal_map_path)





