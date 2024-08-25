@tool
extends StaticBody3D

@export var chunk_size:int = 64
@export var chunk_amount:int = 8
@export var chunk_radius:int = 3
@export var frequency:float = 0.1
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

@export var deformity_level:int = 16
@export var player_body:Node3D

@export var generate_terrain:bool = false:
	set(value):
		generate_terrain = value
		if(generate_terrain):
			_initialize()
	get:
		return generate_terrain 

@export var template_mesh:PlaneMesh = PlaneMesh.new():
	set (value):
		template_mesh = value
	get: 
		return template_mesh

@export var chunks_node:Node = Node.new():
	set (value):
		chunks_node = value
	get: 
		return chunks_node

@export var template_texture:ImageTexture3D = ImageTexture3D.new():
	set (value):
		template_texture = value

	get: 
		return template_texture

@export var collision_shape:CollisionShape3D = CollisionShape3D.new():
	set (value):
		collision_shape = value
	get: 
		return collision_shape

@onready var faces# = template_mesh.get_faces()
@onready var snap# = Vector3.ONE * template_mesh.size.x/2

@export var ext:StaticBody3D:
	get:
		return load("res://demos/demo4/scripts/Terrain4_ext.gd").new()
@export var textures_dir:String = "res://demos/demo4/textures/":
	get:
		return "res://demos/demo4/textures/"
@export var height_map_path:String = "res://demos/demo4/textures/height_map4.png":
	get:
		return "res://demos/demo4/textures/height_map4.png"

@export var normal_map_path:String = "res://demos/demo4/textures/normal_map4.png":
	get:
		return "res://demos/demo4/textures/normal_map4.png"

@export var chunks :Dictionary = {}


var surrounding_chunks
var vertices:PackedVector3Array = []
var noise
var player_chunk_position = Vector3.ZERO
var previous_chunk_position = Vector3.ZERO
# Called when the node enters the scene tree for the first time.

func _ready():
	generate_terrain = true
	_initialize()

func _initialize():
	_generate_chunks()
	print("_generate_chunks has finished")
	_init_chunks()
	print("_init_chunks has finished")
	print("player_chunk_position: " + str(player_chunk_position))

func _process(delta):
	if(generate_terrain):
		oberserve_player_movement()
	#_init_chunks()
	#pass

func oberserve_player_movement():
	#print("player_chunk_position: " + str(player_chunk_position))
	player_chunk_position = ext._get_chunk_coords(player_body.global_position, chunk_size)*chunk_size
	#if previous_chunk_position != player_chunk_position:
		#print("player_chunk_position: " + str(player_chunk_position))
		#print("previous_chunk_position: " + str(previous_chunk_position))
	#if(previous_chunk_position != player_chunk_position):
	if chunks.has(player_chunk_position) && !chunks[player_chunk_position].instance.is_inside_tree(): #!chunks[player_chunk_position].instance.is_inside_tree()
		print("New Chunk: ", chunks[player_chunk_position])
		var chunk = chunks[player_chunk_position]#.instance
		chunks_node.add_child(chunk.instance)

	if !chunks.has(player_chunk_position): #!chunks[player_chunk_position].instance.is_inside_tree()
		print("Create Chunk: ", player_chunk_position)
		var generated_chunk = _generate_chunk(player_chunk_position)
		chunks[player_chunk_position] = generated_chunk
		
	previous_chunk_position = player_chunk_position




func _init_chunks():
	
	if chunks.size() == 0:
		return

	if player_body == null:
		print("no physics body")
		return
	else:

		player_chunk_position = ext._get_chunk_coords(player_body.global_position, chunk_size) #/ chunk_size
		for chunk in chunks.values():
			#print("#chunk: " + str(chunk))
			pass
		surrounding_chunks = []
		var unloading_chunks = []
		for x in range(-chunk_radius, chunk_radius):
			for z in range(-chunk_radius, chunk_radius):
				var chunk_coords = Vector3((player_chunk_position.x + x), 0, (player_chunk_position.z + z))*chunk_size 

				if 	chunks.has(chunk_coords):

					if 	!surrounding_chunks.has(chunk_coords) && !chunks[chunk_coords].instance.is_inside_tree():
						var chunk = chunks[chunk_coords]#.instance
						surrounding_chunks.append(chunk)

					elif !surrounding_chunks.has(chunk_coords) && chunks[chunk_coords].instance.is_inside_tree():
						var chunk = chunks[chunk_coords]#.instance
						unloading_chunks.append(chunk)

		#adding surroundig chunks
		for chunk in surrounding_chunks:
			chunks_node.add_child(chunk.instance)
		
	#	for chunk in chunks:
		#	if chunks[chunk] != null:
			#	if chunks[chunk] != null && chunks[chunk].instance != null && !chunks[chunk].instance.is_inside_tree():
					#print("Remaining chunk: " + str(chunk))
					#chunks[chunk].instance.queue_free()
					#chunks_node.remove_child(chunks[chunk].instance)

			#pass
		#print(chunks)
		#ext._unload_surrounding_chunks(unloading_chunks, chunks, chunks_node)



func _generate_chunks():
	print("_generate_chunks")
	chunks = {}
	randomize()
	noise = FastNoiseLite.new()
	noise.noise_type = noise_type
	noise.frequency = frequency
	noise.seed = randi() 
	#chunks = []
	#DirAccess.remove_absolute(normal_map_path)
	chunks_node = get_node_or_null("Chunks") #Chunks
	if chunks_node == null:
		chunks_node = Node.new()
		chunks_node.name = "Chunks"
		self.add_child(chunks_node)
		chunks_node.set_owner(self)
		print("created chunks node")
	# Clear existing chunks
	for child in chunks_node.get_children():
		child.queue_free()
	
	player_chunk_position = ext._get_chunk_coords(player_body.global_position, chunk_size) #/ chunk_size
	#print("player_chunk: ", ext._get_chunk_coords(player_body.global_position, chunk_size))

	var instances = []
	var offset = Vector3.ZERO
	# Generate chunks
	for x in range(-chunk_amount, chunk_amount):#chunk_amount:
		for z in range(-chunk_amount, chunk_amount):#chunk_amount:
			#offset = Vector3((player_chunk_position.x + x), 0, player_chunk_position.z + z) * chunk_size #adjus to player pos
			offset = Vector3(x, 0, z) * chunk_size #adjust to chunkj size
			#print("offset: " + str(offset))
			var instance = _generate_chunk(offset)
			instances.append(instance)

	for chunk in instances:
		#chunks_node.add_child(chunk.instance)
		#print("chunk: " + str(chunk.name))
		chunks[chunk.name] = chunk
		#print("chunks: " + str(chunks))
		pass
	#print("chunks: " + str(chunks))
	#await get_tree().process_frame
	#.create_timer(1.0).timeout

func _generate_chunk(offset):
	if template_mesh == null:
		print("creating template mesh")
		template_mesh = PlaneMesh.new()

	var plane_mesh = PlaneMesh.new()
	template_mesh = plane_mesh
	
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
	for i in vertices.size():
		var vertex = vertices[i]
		#print("vertex: " + str(vertex))
		var height = noise.get_noise_2d(vertex.x + offset.x, vertex.z + offset.z) * deformity_level
		vertices[i].y = height
		heightmap.append(height)
	vertices = PackedVector3Array(vertices)
	data[ArrayMesh.ARRAY_VERTEX] = vertices

	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)
	
	var chunk_mesh = array_mesh
	var chunk_instance = MeshInstance3D.new()
	chunk_instance.mesh = chunk_mesh
	
	#collision mesh
	var collision_polygon = ConvexPolygonShape3D.new()
	collision_polygon.set_points(vertices)
	collision_shape = CollisionShape3D.new()
	
	var shape_owner = collision_shape
	shape_owner.shape = collision_polygon
	chunk_instance.create_trimesh_collision()
	chunk_instance.add_child(shape_owner)
	collision_shape = shape_owner
	#update to chunk origin
	
	chunk_instance.transform.origin = Vector3(offset.x + chunk_size / 2.0, 0, offset.z + chunk_size / 2.0)  # Update translation to Transform.origin
	#chunk_instance.name = str(offset)
	#print(chunk_instance.name)
	return {
		instance = chunk_instance,
		name = offset
		#heightmap = heightmap,
		#normalmap = normalmap
	}
