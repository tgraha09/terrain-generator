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
@export var generate_terrain:bool:
	set(value):
		_generate_chunks()
		_init_chunks()
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
var vertices:PackedVector3Array = []
var noise
var player_chunk_position = Vector3.ZERO
var previous_position = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_chunks()
	_init_chunks()
		#ext._load_chunk(player_chunk_position, chunks, chunks_node)
		#var offset = player_position * chunk_size

func _process(delta):
	#_init_chunks()
	pass


var surrounding_chunks

func _init_chunks():
	if chunks.size() == 0:
		return

	if player_body == null:
		print("no physics body")
		return
	else:
		#var pos = ext._get_chunk_coords(player_body.position, chunk_size)
		#player_chunk_position = ext._get_chunk_coords(player_body.position, chunk_size)
		#print("pos: " + str(pos))
		#print("player_chunk_position: " + str(player_chunk_position))
		#if pos == player_chunk_position:
			#print("pos == player_chunk_position")
			#return
	#	elif(pos != player_chunk_position):
		#	print("pos != player_chunk_position")
			#player_chunk_position = pos
		#print(player_body.position)
		#print(chunks)W
		for chunk in chunks.values():
			#print("chunk: " + str(chunk))
			pass
		#player_chunk_position = pos
		#print("player_chunk_position: " + str(player_chunk_position))
		#print(Vector3(player_chunk_position.x*chunk_size, 0, player_chunk_position.z*chunk_size))
		#print(chunks)
		var offset = player_chunk_position * chunk_size
		#print("offset: " + str(offset))
		#print(chunks[offset])
		for chunk in chunks.values():
		#	print("chunk: " + str(chunk))
			pass
		surrounding_chunks = []
		var unloading_chunks = []
		for x in range(-chunk_radius, chunk_radius):
			for z in range(-chunk_radius, chunk_radius):
				var chunk_coords = Vector3((player_chunk_position.x + x)*chunk_size, 0, (player_chunk_position.z + z)*chunk_size)
				#print(chunk_coords)
				if 	chunks.has(chunk_coords):
					#print(chunks.find_key(chunk_coords))
					#if(chunks.get(chunk_coords) != null):
					if 	!surrounding_chunks.has(chunk_coords) && !chunks[chunk_coords].instance.is_inside_tree():
						#print("Chunk in list")
						var chunk = chunks[chunk_coords].instance
						surrounding_chunks.append(chunk)

					elif !surrounding_chunks.has(chunk_coords) && chunks[chunk_coords].instance.is_inside_tree():
						var chunk = chunks[chunk_coords].instance
						unloading_chunks.append(chunk)

				
		
		#print(surrounding_chunks)
		ext._load_surrounding_chunks(surrounding_chunks, chunks_node)
		
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
	#chunks = []
	#DirAccess.remove_absolute(normal_map_path)
	chunks_node = get_node_or_null("Chunks") #Chunks
	if chunks_node == null:
		chunks_node = Node.new()
		chunks_node.name = "Chunks"
		self.add_child(chunks_node)

	# Clear existing chunks
	for child in chunks_node.get_children():
		child.queue_free()
	
	var instances = []
	var offset = Vector3.ZERO
	# Generate chunks
	for x in chunk_amount:
		for z in chunk_amount:
			offset = Vector3(x, 0, z) * chunk_size
			var instance = _generate_chunk(offset)
			instances.append(instance)

	for chunk in instances:
		#chunks_node.add_child(chunk.instance)
		chunks[chunk.name] = chunk
		pass
	#print("chunks: " + str(chunks))

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

	randomize()
	noise = FastNoiseLite.new()
	noise.noise_type = noise_type
	noise.frequency = frequency
	noise.seed = randi() 

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var data = surface_tool.commit_to_arrays()
	vertices = PackedVector3Array(data[ArrayMesh.ARRAY_VERTEX])
	var heightmap:Array = []
	var normalmap:Array = []
	for i in vertices.size():
		var vertex = vertices[i]
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
	
	chunk_instance.transform.origin = Vector3(offset.x + chunk_size / 2, 0, offset.z + chunk_size / 2)  # Update translation to Transform.origin
	#chunk_instance.name = str(offset)
	#print(chunk_instance.name)
	return {
		instance = chunk_instance,
		name = offset
		#heightmap = heightmap,
		#normalmap = normalmap
	}
