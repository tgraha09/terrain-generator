@tool
extends StaticBody3D

@export var chunk_size:int = 64
@export var chunk_amount:int = 8
@export var chunk_radius:int = 3
@export var player_chunk_radius:int = 2:
	set(value):
		player_chunk_radius = value
	get:
		return player_chunk_radius
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
var origin_position
var previous_player_position
var red 
var blue
#ed.albedo_color = Color.RED
# Called when the node enters the scene tree for the first time.

func _ready():
	generate_terrain = true
	
	_initialize()

func _initialize():
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
		chunks_node.remove_child(child)
		#chunks_node.queue_free()
		#print("deleted child: " + str(child))
	#print("Terrain origin_position: " + str(origin_position))
	_generate_chunks()
	print("_generate_chunks has finished")
	_init_chunks()
	print("_init_chunks has finished")

	#print("player_chunk_position: " + str(player_chunk_position))

func _process(delta):
	if(generate_terrain):
		oberserve_player_movement()
	#_init_chunks()
	#pass

func get_point_in_front(distance):
	var direction = player_body.global_transform.basis.z* -1  # Get the direction the player is facing
	var point_in_front = player_body.global_transform.origin + direction * distance
	return point_in_front

func oberserve_player_movement():
	#print("player_chunk_position: " + str(player_chunk_position))
	player_chunk_position = ext._get_chunk_coords(player_body.global_position, chunk_size)*chunk_size
	var player_radius = player_chunk_radius
	#var point  = get_point_in_front(chunk_size*player_radius) #* (chunk_size*player_radius)

	var surrounding_player_offsets = []
			#var unloading_chunks = []
	
	if previous_player_position != player_body.global_position:
		for x in range(-player_radius, player_radius):#chunk_amount:
			for z in range(-player_radius, player_radius):#chunk_amount:
				var offset = Vector3((player_chunk_position.x + (x*chunk_size)), 0, player_chunk_position.z + (z * chunk_size)) #adjus to player pos
				surrounding_player_offsets.append(offset)
				if !chunks.has(offset):
					#print("offset: " + str(offset))
					#var generated_chunk = _generate_chunk(offset)
					#generated_chunk.instance.material_override = red
					#chunks[offset] = generated_chunk
					#chunks_node.add_child(generated_chunk.instance)
					chunk_amount += chunk_amount/4
					#print("chunk_amount: " + str(chunk_amount))
					_generate_chunks()
				elif chunks.has(offset):
					chunks[offset].instance.material_override = blue
					if !chunks[offset].instance.is_inside_tree():
						chunks_node.add_child(chunks[offset].instance)

		for key in chunks:
			var chunk = chunks[key]
			if chunk.instance.is_inside_tree() && !surrounding_player_offsets.has(key):
				#chunk.instance.queue_free()
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

					elif !surrounding_chunks.has(chunk_coords) && chunks[chunk_coords].instance.is_inside_tree():
						var chunk = chunks[chunk_coords]#.instance
						unloading_chunks.append(chunk)

		#adding surroundig chunks
		for chunk in surrounding_chunks:
			chunks_node.add_child(chunk.instance)



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
