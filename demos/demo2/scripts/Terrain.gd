@tool
extends StaticBody3D


@export var generate_mesh:bool = false : #set = _generate_mesh 
	set (value):
		_generate_chunks()
		

#@export var physics_body:Node3D
#@export var template_mesh:PlaneMesh
#@onready var faces = template_mesh.get_faces()
#@onready var snap = Vector3.ONE * template_mesh.size.x/2
		
@export var frequency:float = 0.1 :
	set (value):
		frequency = value
	get: 
		return frequency
		
@export var deformity_level:int = 16 :
	set (value):
		deformity_level = value
	get: 
		return deformity_level
		
@export var chunk_size:int = 16 :
	set (value):
		chunk_size = value
	get: 
		return chunk_size
		
@export var template_mesh:PlaneMesh = PlaneMesh.new():
	set (value):
		template_mesh = value
		print(template_mesh.size)
	get: 
		return template_mesh
		
@export var heightmap_array:Array = []:set = _set_heightmap_data, get = _get_heightmap_data		

#print(heightmap_array.max())

		
var heightmap_data:Array = []
var normalmap_data:Array = []
var image:Image = Image.new()
func _get_template_mesh():
	return template_mesh
	
func _get_heightmap_data():
	return heightmap_data
	
func _set_heightmap_data(_data):
	heightmap_data = _data

func _ready():
	_generate_chunks()


func _generate_chunks():
	print("_generate_chunks")
	
	var chunks_node = get_node_or_null("Chunks")
	if chunks_node == null:
		chunks_node = Node.new()
		chunks_node.name = "Chunks"
		self.add_child(chunks_node)
	
	var chunks = []
	
	# Clear existing chunks
	for child in chunks_node.get_children():
		child.queue_free()

	#print("chunk_size")
	#print(chunk_size)
	# Generate chunks
	#var image := Image.new()
	image.create(chunk_size, chunk_size, false, Image.FORMAT_RGB8)
	var chunk_offset = Vector3.ZERO
	while chunk_offset.x < chunk_size:
		while chunk_offset.z < chunk_size:
			var chunk_mesh = _generate_chunk(chunk_offset, chunk_offset.x, chunk_offset.z)
			var chunk_instance = MeshInstance3D.new()
			chunk_instance.mesh = chunk_mesh
			chunk_instance.transform.origin = Vector3(chunk_offset.x, 0, chunk_offset.z)  # Update translation to Transform.origin
			chunks_node.add_child(chunk_instance)
			chunks.append(chunk_instance)
			chunk_offset.z += chunk_size
		chunk_offset.z = 0
		chunk_offset.x += chunk_size




func _generate_chunk(offset, _x, _z):
	
	#print(offset)
	#print(chunk_size)
	var plane_mesh = template_mesh
	
	plane_mesh.size = Vector2.ONE * chunk_size
	#plane_mesh.size.x = chunk_size
	#plane_mesh.size.y = chunk_size
	#print(plane_mesh.size)
	plane_mesh.subdivide_width = chunk_size - 1
	plane_mesh.subdivide_depth = chunk_size - 1

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var data = surface_tool.commit_to_arrays()
	var vertices = data[ArrayMesh.ARRAY_VERTEX]
	randomize()
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = frequency
	noise.seed = randi()
	
	#var heightM = heightmap_data
	heightmap_data = Array()
	normalmap_data = Array()
	
	for i in vertices.size():
		var vertex = vertices[i]
		var height = noise.get_noise_2d(vertex.x + offset.x, vertex.z + offset.z) * deformity_level
		vertices[i].y = height
		heightmap_data.append(height)
		#var color = Color(height, height, height)
		#image.set_pixel(_x, _z, color)

	data[ArrayMesh.ARRAY_VERTEX] = vertices

	calculate_normal_map(heightmap_data, chunk_size, chunk_size)

	#var shader_material = ShaderMaterial.new()
	#shader_material.shader = load("res://demos/demo2/shaders/terrainShader.gdshader")
	#shader_material.set_shader_parameter("heightmap_data", heightmap_data)
	#shader_material.set_shader_parameter("normalmap_data", normalmap_data)
	heightmap_array = heightmap_data
	_set_heightmap_data(heightmap_data)
	#print(heightmap_data)
	
	#$Collisionmap.heightmap_data = heightmap_data
	#print($Collisionmap.heightmap_data)
	#ProjectSettings.set_setting("global/heightmap_data2", heightmap_data)
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)

	return array_mesh
	
	var collisionMapGD = load("res://demos/demo2/collisionmap/collisionmap.gd")
	collisionMapGD.set("template_mesh", plane_mesh)
	#ProjectSettings.set_setting("global/terrainMesh", plane_mesh)
	#ProjectSettings.save()


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
		
