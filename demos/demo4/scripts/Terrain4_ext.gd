extends "res://demos/demo4/scripts/Terrain4.gd"


func _get_chunk_coords(_position, _chunk_size):
	#print("Math: ",_position.x / (_chunk_size))
	#print("Floor: ",floor(_position.x / (_chunk_size)))
	return Vector3(round((_position.x / _chunk_size)), 0, round((_position.z / _chunk_size)))




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
