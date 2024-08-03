@tool
extends MeshInstance3D

@export var frequency:float = 0.1
@export var deformity_level:int = 16
@export var chunk_size:int = 16
@export var chunk_amount:int = 16
@export var physics_body:Node3D
@export var generate_terrain:bool:
	set(value):
		_generate_chunks()
		#_create_map()
	get:
		return generate_terrain 

@export var template_mesh:PlaneMesh = PlaneMesh.new():
	set (value):
		template_mesh = value
		print(template_mesh.size)
	get: 
		return template_mesh

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
var heightmap:Array = []
var normalmap:Array = []
var vertices:PackedVector3Array = []
@export var textures_dir:String = "res://demos/demo4/textures/":
	get:
		return "res://demos/demo4/textures/"
@export var height_map_path:String = "res://demos/demo4/textures/height_map4.png":
	get:
		return "res://demos/demo4/textures/height_map4.png"

@export var normal_map_path:String = "res://demos/demo4/textures/normal_map4.png":
	get:
		return "res://demos/demo4/textures/normal_map4.png"
# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_chunks()
	#if template_mesh != null:
		#_create_map()
	#update_shape()
	#pass # Replace with function body.

func _physics_process(delta):
	if physics_body == null:
		print("no physics body")
		return
	#var player_rounded_position = physics_body.global_position.snapped(snap) * Vector3(1,0,1)
	#if not global_position == player_rounded_position:
		#global_position = player_rounded_position
		#update_shape()

func _generate_chunks():
	print("_generate_chunks")

	#DirAccess.remove_absolute(normal_map_path)
	var chunks_node = get_node_or_null("Chunks") #Chunks
	if chunks_node == null:
		chunks_node = Node.new()
		chunks_node.name = "Chunks"
		self.add_child(chunks_node)
	
	#var chunks = []
	
	# Clear existing chunks
	for child in chunks_node.get_children():
		child.queue_free()

	var chunk_offset = Vector3.ZERO
	while chunk_offset.x < chunk_size:
		while chunk_offset.z < chunk_size:
			var chunk_instance = _generate_chunk(chunk_offset, chunk_offset.x, chunk_offset.z)
			chunks_node.add_child(chunk_instance)
			#chunks.append(chunk_instance)
			chunk_offset.z += chunk_size
			
		chunk_offset.z = 0
		chunk_offset.x += chunk_size

	save_heightmap_and_normal_map(chunk_size, heightmap, normalmap)

func save_heightmap_and_normal_map(chunk_size, heightmap, normalmap):

	#DirAccess.make_dir_absolute(textures_dir)

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


			heightmap_image.set_pixel(x, y, Color(normalized_height, normalized_height, normalized_height))
			normal_map_image.set_pixel(x, y, Color(normal.x, normal.y, normal.z))

	

	heightmap_image.save_png(height_map_path)
	normal_map_image.save_png(normal_map_path)


func _generate_chunk(offset, _x, _z):
	if template_mesh == null:
		print("creating template mesh")
		template_mesh = PlaneMesh.new()
	#print(offset)
	#print(chunk_size)

	var plane_mesh = template_mesh
	
	plane_mesh.size = Vector2.ONE * chunk_size
	plane_mesh.size.x = chunk_size
	plane_mesh.size.y = chunk_size
	#print(plane_mesh.size)
	plane_mesh.subdivide_width = chunk_size - 1
	plane_mesh.subdivide_depth = chunk_size - 1

	randomize()
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = frequency
	noise.seed = randi() 

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var data = surface_tool.commit_to_arrays()
	vertices = PackedVector3Array(data[ArrayMesh.ARRAY_VERTEX])#data[ArrayMesh.ARRAY_VERTEX]
	#data[ArrayMesh.ARRAY_VERTEX] = vertices
	
	for i in vertices.size():
		var vertex = vertices[i]
		var height = noise.get_noise_2d(vertex.x + offset.x, vertex.z + offset.z) * deformity_level
		#vertices[i].y = height
		heightmap.append(height)

	vertices = PackedVector3Array(vertices)
	data[ArrayMesh.ARRAY_VERTEX] = vertices

	normalmap = calculate_normal_map(heightmap, chunk_size, chunk_size)

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
	#chunk_instance.add_child(shape_owner)
	collision_shape = shape_owner
	#update to chunk origin
	chunk_instance.transform.origin = Vector3(offset.x, 0, offset.z)  # Update translation to Transform.origin

	return chunk_instance

func update_shape():
	print("update shape")
	#faces = template_mesh.get_faces()
	#print(faces.count())
	#snap = Vector3.ONE * template_mesh.size.x/2
	#for i in faces.size():
		#var global_vert = faces[i] + global_position
		#faces[i].y = HeightMap.get_height(global_vert.x, global_vert.y)
	#collision_shape.set_faces(faces)



func calculate_normal_map(heightmap_data, width, height):
	var normal_map_data = []
	
	for y in range(height):
		for x in range(width):
			var x_l = heightmap_data[y * width + (x - 1)] if x > 0 else heightmap_data[y * width + x]
			var x_r = heightmap_data[y * width + (x + 1)] if x < width - 1 else heightmap_data[y * width + x]
			var y_u = heightmap_data[(y - 1) * width + x] if y > 0 else heightmap_data[y * width + x]
			var y_d = heightmap_data[(y + 1) * width + x] if y < height - 1 else heightmap_data[y * width + x]

			var tangent = Vector3(2.0, (x_r - x_l) * 0.5, 0.0)
			var bitangent = Vector3(0.0, (y_d - y_u) * 0.5, 2.0)

			var normal = tangent.cross(bitangent)
			normal = normal.normalized()

			normal_map_data.append(normal)

	return normal_map_data
