@tool
extends StaticBody3D

@export var chunk_size:int = 8
@export var chunk_amount:int = 16
@export var chunk_radius:int = 8
@export var player_chunk_radius:int = 2:
	set(value):
		player_chunk_radius = value
	get:
		return player_chunk_radius
@export var frequency:float = 0.01
@export var noise_type:int = 3:
	set(value):
		
		if(value <0):
			noise_type = 0
		elif value > 6:
			noise_type = 6
		else:
			noise_type = value
	get:
		
		return noise_type

@export var deformity_level:int = 32
@export var player_body:Node3D

@export var generate_terrain:bool = false:
	set(value):
		generate_terrain = value
		if(generate_terrain):
			_initialize()
			#generate_terrain = false
	get:
		return generate_terrain 

@export var chunks_node:MeshInstance3D = MeshInstance3D.new():
	set (value):
		chunks_node = value
	get: 
		return chunks_node

@export var ext:StaticBody3D: # = load("res://demos/demo4/scripts/Terrain4_ext.gd").new()
	get:
		return load("res://demos/demo4/scripts/Terrain4_ext.gd").new()

var chunks :Dictionary = {}


var surrounding_chunks
var vertices:PackedVector3Array = []
var noise
var player_chunk_position = Vector3.ZERO
var previous_chunk_position = Vector3.ZERO
var origin_position
var previous_player_position
var red 
var blue
#@export var grass_color: Color # Color = Color(0.2, 0.8, 0.2)
#@export var water_color: Color


#@export var water_color = Color(0.2, 0.4, 0.8)
#@export var dirt_color = Color(0.6, 0.4, 0.2)


		
@export var terrain_material:Material: #= load("res://demos/demo4/shaders/terrain_material.tres"): #load("res://demos/demo4/shaders/terrain_shader.gdshader"):
	set (value):
		terrain_material = value
	get: 
		return terrain_material


"@export var terrain_shader:Shader:# = load():
	set (value):
		terrain_shader = value
	get: 
		return terrain_shader"

func _ready():
	generate_terrain = true
	#queue_free()
	_initialize()
	#add_child(chunks_node)
	#print(self)

func _initialize():
	
	#terrain_shader = load("res://demos/demo4/shaders/terrain_shader.gdshader")
	#print("TPE: ",typeof(terrain_shader))
	red = StandardMaterial3D.new()
	blue = StandardMaterial3D.new()
	red.albedo_color = Color.RED
	blue.albedo_color = Color.BLUE
	origin_position = Vector3.ZERO
	previous_player_position = Vector3.ZERO
	#origin_position = global_position
	chunks = {}
	randomize()
	noise = FastNoiseLite.new()
	noise.noise_type = noise_type
	noise.frequency = frequency
	noise.seed = randi() 
	#chunks = []
	chunks_node = get_node_or_null("Chunks")
	if chunks_node == null:
		print("created chunks node")
		return
		
	for child in chunks_node.get_children():
		chunks_node.remove_child(child)

	_generate_chunks()
	print("_generate_chunks has finished")
	_init_chunks()
	print("_init_chunks has finished")


func _process(delta):
	if(generate_terrain):
		oberserve_player_movement()
	#_init_chunks()
	#pass

func resize_terrain(_frac):
	chunk_amount = chunk_amount + (chunk_amount/_frac)
	print("chunk_amount: " + str(chunk_amount))
	_generate_chunks()

func oberserve_player_movement(): 
	#print("player_chunk_position: " + str(player_chunk_position))
	player_chunk_position = ext._get_chunk_coords(player_body.global_position, chunk_size)*chunk_size
	var player_radius = player_chunk_radius
	var surrounding_player_offsets = []
	var surrounding_player_chunks = []
	if previous_player_position != player_body.global_position:
		for x in range(-player_radius, player_radius):#chunk_amount:
			for z in range(-player_radius, player_radius):#chunk_amount:
				var offset = Vector3((player_chunk_position.x + (x*chunk_size)), 0, player_chunk_position.z + (z * chunk_size)) #adjus to player pos
				surrounding_player_offsets.append(offset)
				if !chunks.has(offset):
					#resize_terrain(4)
					var welp = null 
				elif chunks.has(offset):
					#chunks[offset].instance.material_override = terrain_shader#blue
					if !chunks[offset].instance.is_inside_tree():
						surrounding_player_chunks.append({
							offset = offset,
							instance = chunks[offset].instance
						})
						chunks_node.add_child(chunks[offset].instance)
		
		for key in chunks:
			var chunk = chunks[key]
			if chunk.instance.is_inside_tree() && !surrounding_player_offsets.has(key):
				if chunk.isSpawned== true:
					chunk.isSpawned = false
					#print("chunk is spawned")
				#chunk.instance.queue_free()
				#print("key: " + str(key))
				chunks_node.remove_child(chunk.instance)
				#chunks[key].instance.material_override = red
				
	previous_player_position = player_body.global_position	
	previous_chunk_position = player_chunk_position

func _init_chunks():
	
	if chunks.size() == 0:
		return

	if player_body == null:
		print("no physics body")
		return
	else:
		#player_chunk_position = ext._get_chunk_coords(player_chunk_position, chunk_size)
		var origin_chunk_position:Vector3 = ext._get_chunk_coords(origin_position, chunk_size)
		
		#	pass
		surrounding_chunks = []
		var unloading_chunks = []
		for x in range(-chunk_radius, chunk_radius):
			for z in range(-chunk_radius, chunk_radius):
				var chunk_coords = Vector3((origin_chunk_position.x + x), 0, (origin_chunk_position.z + z))*chunk_size 
				if 	chunks.has(chunk_coords):
					if 	!surrounding_chunks.has(chunk_coords) && !chunks[chunk_coords].instance.is_inside_tree():
						var chunk = chunks[chunk_coords]#.instance
						surrounding_chunks.append(chunk)

		#adding surroundig chunks
		for chunk in surrounding_chunks:
			chunks_node.add_child(chunk.instance)
			chunks[chunk.name].isSpawned = true


func _generate_chunks():
	print("_generate_chunks")
	
	print("chunk_amount: " + str(chunk_amount))
	var instances = []
	var offset = Vector3.ZERO
	# Generate chunks
	for x in range(-chunk_amount, chunk_amount):#chunk_amount:
		for z in range(-chunk_amount, chunk_amount):#chunk_amount:
			#offset = Vector3((player_chunk_position.x + x), 0, player_chunk_position.z + z) * chunk_size #adjus to player pos
			offset = Vector3(x, 0, z) * chunk_size #adjust to chunkj size
			if !chunks.has(offset):
				var instance = _generate_chunk(offset)
				instances.append(instance)
	for chunk in instances:
		chunks[chunk.name] = chunk
		pass


func _generate_chunk(offset):
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2.ONE * chunk_size
	plane_mesh.size.x = chunk_size
	plane_mesh.size.y = chunk_size
	plane_mesh.subdivide_width = chunk_size - 1
	plane_mesh.subdivide_depth = chunk_size - 1

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var data = surface_tool.commit_to_arrays()
	vertices = PackedVector3Array(data[ArrayMesh.ARRAY_VERTEX])
	var heightmap:Array = []
	#var normalmap:Array = []
	var max_height = 0
	var min_height = 0
	for i in vertices.size():
		var vertex = vertices[i]
		#print("vertex: " + str(vertex))
		var height = noise.get_noise_2d(vertex.x + offset.x, vertex.z + offset.z) * deformity_level
		vertices[i].y = height
		if height > max_height:
			max_height = height
		if height < min_height:
			min_height = height
		heightmap.append(height)
	vertices = PackedVector3Array(vertices)
	data[ArrayMesh.ARRAY_VERTEX] = vertices
	#print("max_height: " + str(max_height))
	#print("min_height: " + str(min_height))
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)
	
	var chunk_mesh = array_mesh
	var chunk_instance = MeshInstance3D.new()
	chunk_instance.mesh = chunk_mesh
	
	#collision mesh
	var collision_polygon = ConvexPolygonShape3D.new()
	collision_polygon.set_points(vertices)
	
	#collision_shape.visible = false
	var shape_owner = CollisionShape3D.new()
	shape_owner.shape = collision_polygon
	#shape_owner.visible = false
	chunk_instance.create_trimesh_collision()
	chunk_instance.add_child(shape_owner)
	
	#update to chunk origin
	chunk_instance.transform.origin = Vector3(offset.x + chunk_size / 2.0, 0, offset.z + chunk_size / 2.0)  # Update translation to Transform.origin
	#chunk_instance.name = str(offset)
	#print(chunk_instance.name)
	#var material = ShaderMaterial.new()
	
	#shader.code = terrain_shader_code.source_code
	#material.shader = terrain_shader
	#terrain_material.shader = terrain_shader
	#terrain_material.set_shader_parameter("grass_color", grass_color)
	#terrain_material.set_shader_parameter("water_color", water_color)
	#terrain_material.set_shader_parameter("dirt_color", dirt_color)

	chunk_instance.material_override = terrain_material
	#chunk_instance.material_override = material
	#update_shader(chunk_instance.material_override, max_height, min_height)
	return {
		instance = chunk_instance,
		name = offset,
		offset = offset,
		isSpawned = false,
		#heightmap = heightmap,
		#normalmap = normalmap 
	}
