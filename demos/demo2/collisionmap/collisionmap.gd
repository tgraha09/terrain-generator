extends CollisionShape3D
@export var physics_body:Node3D

@onready var template_mesh:PlaneMesh = get_parent()._get_template_mesh() #.get("mesh") #= ProjectSettings.get_setting("global/terrainMesh")
@onready var faces = template_mesh.get_faces()
@onready var snap = Vector3.ONE * template_mesh.size.x/2
@onready var heightmap_data: Array = [] #get_parent()._get_heightmap_data()

var image: Image

func _ready():
	
	heightmap_data = get_parent().heightmap_data # _get_heightmap_data() #._get_
	#print(get_parent().heightM)
	 #get_parent().heightmap_array
	image = get_parent().image
	print(heightmap_data)
	print(template_mesh.size.x)
	print(image.data)
	#_save_to_image()
	_update_shape()

#func _physics_process(delta):
	
	#var data = ProjectSettings.get_setting("global/heightmap_data2")
	#print(data)
	#print(heightmap_data.size())
	#var player_rounded_position = physics_body.global_position.snapped(snap) * Vector3(1,0,1)
	#if not global_position == player_rounded_position:
		#global_position = player_rounded_position
		#update_shape()

func _update_shape():
	var mesh_tool = MeshDataTool.new()
	
	# Create a temporary ArrayMesh and set the PlaneMesh as its mesh
	var temp_mesh = ArrayMesh.new()
	temp_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, template_mesh.get_mesh_arrays())
	# Create a reference to the surface of the ArrayMesh
	mesh_tool.create_from_surface(temp_mesh, 0)
	var vertex_count = mesh_tool.get_vertex_count()
	print(vertex_count)
	_set_heightmap_to_collision_mesh(template_mesh, vertex_count, heightmap_data)
	for i in faces.size():
		var global_vert = faces[i] + global_position
		#var height_data = heightmap_data.get_pixel(global_vert.x, global_vert.z)
		#faces[i].y = height_data.r * YOUR_HEIGHT_SCALE_FACTOR
	shape.set_faces(faces)
	
	
func _set_heightmap_to_collision_mesh(template_mesh: PlaneMesh, vertex_count: int, heightmap_data: Array):
	var mesh_tool = MeshDataTool.new()
	
	# Create a temporary ArrayMesh and set the PlaneMesh as its mesh
	var temp_mesh = ArrayMesh.new()
	temp_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, template_mesh.get_mesh_arrays())

	# Create a reference to the surface of the ArrayMesh
	mesh_tool.create_from_surface(temp_mesh, 0)

	for i in range(vertex_count):
		mesh_tool.set_vertex(i, Vector3(mesh_tool.get_vertex(i).x, heightmap_data[i], mesh_tool.get_vertex(i).z))

	# Update the surface with the modified vertices
	mesh_tool.commit_to_surface(temp_mesh, 0)

	# Assign the updated mesh as the collision shape
	if self.shape:
		print(self.shape)
	
	
	#image = Image.create_from_data(template_mesh.size.x, template_mesh.size.y, false, Image.FORMAT, heightmap_data)
	#image.save_png("res://demos/demo2/heightmap/heightmap.png")

	
