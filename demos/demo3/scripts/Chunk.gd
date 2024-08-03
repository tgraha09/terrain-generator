extends Node3D


var mesh_instance
var noise
var x
var z
var chunk_size
var key
var deformity_level
var heightmap = []
@export var template_mesh:PlaneMesh = PlaneMesh.new():
	set (value):
		template_mesh = value
		print(template_mesh.size)
	get: 
		return template_mesh

func _init(options, x, z, chunk_size):
	#print("Chunk Init: " + str(x) + "," + str(z))
	self.x = x
	self.z = z
	deformity_level = options.deformity_level
	noise = options.noise #FastNoiseLite.new()
	#randomize()
	noise.noise_type = options.noise_type
	noise.fractal_octaves = options.fractal_octaves
	noise.frequency = options.frequency
	#noise.seed = randi()
	print(noise.seed)
	key = str(x) + "," + str(z)
	self.chunk_size = chunk_size
	#translate(Vector3(x*chunk_size, 0, z*chunk_size))
	transform.origin = Vector3(x*chunk_size, 0, z*chunk_size)
	print(transform.origin)
	#ISSUE SETTING THE POSITION
	#self.translate(Vector3(x*chunk_size, 0, z*chunk_size))
	#self.transform.origin = Vector3(x*chunk_size, 0, z*chunk_size)
	
	

func _ready():
	generate_chunk()

func set_chunk_origin(vec):
	print(self.transform.origin)
	self.transform.origin = vec
	print(self.transform.origin)

func generate_chunk():
	#print("Generating Chunk: " + str(x) + "," + str(z))
	var plane_mesh = PlaneMesh.new()
	mesh_instance = MeshInstance3D.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * 0.5
	plane_mesh.subdivide_width = chunk_size * 0.5
	template_mesh = plane_mesh

	#apply material
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	#create a mesh from the plane mesh
	surface_tool.create_from(template_mesh, 0)

	var array_mesh = surface_tool.commit()
	var data = surface_tool.commit_to_arrays()
	var error = data_tool.create_from_surface(array_mesh, 0)
	var vertices = data[ArrayMesh.ARRAY_VERTEX]

	var collision_shape = ConvexPolygonShape3D.new()
	collision_shape.set_points(vertices)

	for i in vertices.size(): #range(data_tool.get_vertex_count()):
		var vertex = vertices[i] # vertices[i]#data_tool.get_vertex(i)

		var height = noise.get_noise_3d(vertex.x+x, vertex.y, vertex.z+z)* deformity_level
		vertex.y = height
		vertices[i].y = height
		heightmap.append(height)
		#print(height)
		#print(vertex)
		data_tool.set_vertex(i, vertex)
	
	#for s in range(array_plane.get_surface_count()):
		#array_plane.surface_set_material(s, null)

	data[ArrayMesh.ARRAY_VERTEX] = vertices
	var new_array_mesh = ArrayMesh.new()
	new_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)
	#mesh_instance.mesh = new_array_mesh
	#mesh_instance.create_trimesh_collision()  # Create a trimesh collision shape
	#mesh_instance.collision_shape = collision_shape  # Assign the collision shape to the MeshInstance3D
	
	var collision_polygon = ConvexPolygonShape3D.new()
	collision_polygon.set_points(vertices)
	
	var shape_owner = CollisionShape3D.new()
	shape_owner.shape = collision_polygon
	

	mesh_instance.mesh = new_array_mesh
	mesh_instance.create_trimesh_collision()
	mesh_instance.add_child(shape_owner)
	collision_shape = shape_owner
	collision_shape.owner = mesh_instance
	#data_tool.commit_to_surface(array_mesh)
	#surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	#surface_tool.create_from(array_mesh, 0)
	#surface_tool.generate_normals()

	#surface_tool.commit(mesh_instance.mesh)
	#print("Noise Seed: " + str(noise.seed))
	#mesh_instance = MeshInstance3D.new()
	#mesh_instance.mesh = surface_tool.commit()
	#mesh_instance.create_trimesh_collision()
	#mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	#print("Adding Mesh Instance: " + str(x) + "," + str(z))
	add_child(mesh_instance)

func print_chunk():
	print("Chunk: " + str(self.x) + "," + str(self.z))
	
