@tool
extends Node3D

@export var initialize_world:bool = false:
	set(value):
		_init_world()

@export var chunk_size:int = 64
@export var chunk_amount:int = 16
var chunks = {}
var unready_chunks = {}
var thread
var threads = []
var active_threads = 0
@export var fractal_octaves = 6
#@export var fractal_type = 0 # 0 = simplex, 1 = fbm, 2 = ridged, 3 = cellular, 4 = perlin
# 0 = simplex, 1 = perlin, 2 = fbm, 3 = ridged, 4 = cellular
#@export var noise_type = 1 

@export var frequency:float = 0.1 
@export var deformity_level:int = 16
#@export var period = 80

var noise
var noise_type = FastNoiseLite.TYPE_PERLIN

func _ready():
	_init_world()
	update_chunks()
	
# Called when the node enters the scene tree for the first time.
func _init_world():
	print("Generating World")
	
	#create the noise
	#noise = FastNoiseLite.new()
	#specify noise parameters
	fractal_octaves = fractal_octaves
	noise_type = noise_type#noise_type
	frequency = frequency
	#self.seed = randi()
	#print(noise.seed)
	#noise.period = period
	#create thread for world generation
	noise = FastNoiseLite.new()
	randomize()
	noise.noise_type = noise_type
	noise.fractal_octaves = fractal_octaves
	noise.frequency = frequency
	noise.seed = randi()
	thread = Thread.new()


	#print(thread.is_started())

#adds chunk by key of x,z
func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	#print(thread.is_started())
	#print(thread.is_alive())
	
	#print("Add Chunk: " + key)
	#if we already have a key, then the thread is active for the chunk
	if(chunks.has(key)): 
		#print("Key Present: " + key)
		return

	#if we dont have a key, then the thread is not active for the chunk
	if not thread.is_started():
		self.active_threads += 1
		var new_thread = Thread.new()
		threads.append(new_thread)
		new_thread.start(self.load_chunk.bind([thread, x, z]), 1)
		#thread.start(load_chunk.bind([thread, x, z]), 1)
		#unready_chunks[key] = 1

func load_chunk(args):
	#print("Loading Chunk")
	#script to create a chunk
	const Chunk = preload("Chunk.gd") 
	#get thread and x,z
	var thread = args[0]
	#print(thread.get_id()) 
	var x = args[1]
	var z = args[2]
	
	#print("Loading Chunk: " + str(x) + "," + str(z))
	#sets the chunk position based on the player position
	var chunk_x = x * chunk_size
	var chunk_z = z * chunk_size
	#randomize()
	#noise = FastNoiseLite.new()
	
	#noise.noise_type = self.noise_type
	#noise.fractal_octaves = fractal_octaves
	#noise.frequency = frequency

	var options = {
		"noise_type": noise_type,
		"fractal_octaves": fractal_octaves,
		"frequency": frequency,
		"deformity_level": deformity_level,
		"noise": noise
	}

	
	#creates the chunk from the noise, chunk size and location
	var chunk = Chunk.new(options, chunk_x, chunk_z, chunk_size)
	#chunk.print_chunk()

	load_done(chunk, thread)
	#thread.chunk
	#sets the chunk origin position
	#print(chunk.transform.origin)
	
	#chunk.set_chunk_origin(Vector3(chunk_x, 0, chunk_z))
	#chunk.transform.origin = Vector3(chunk_x, 0, chunk_z)
	#chunk.call_deferred("set_chunk_origin", Vector3(chunk_x, 0, chunk_z))
	
	#thread.call_deferred("load_done", chunk, thread)


	


func load_done(chunk, thread):
	#get the key of the chunk also equals player x,z
	var key = str(chunk.x/chunk_size) + "," + str(chunk.z/chunk_size)
	#add_child(chunk)
	call_deferred("add_child", chunk)
	chunks[chunk.key] = chunk
	unready_chunks.erase(key)
	self.active_threads -= 1
	#thread.wait_to_finish()

func get_chunk (x, z):
	var key = str(x) + "," + str(z)	
	if chunks.has(key):
		return chunks.get(key)
	return null

func update_chunks():
	#print("Updating Chunks")
	
	var player_transform = $PlayerCharacter.transform
	var p_x = int(player_transform.origin.x) / chunk_size
	var p_z = int(player_transform.origin.z) / chunk_size
	
	for x in range(p_x - chunk_amount*.5, p_x + chunk_amount*.5):
		for z in range(p_z - chunk_amount*.5, p_z + chunk_amount*.5):
			#print("Checking Chunk: " + str(x) + "," + str(z))
			add_chunk(x, z)	

	
	print("Active Threads: " + str(active_threads))

	return

func clean_up_chunks():
	return

func reset_chunks():
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#update_chunks()
	#clean_up_chunks()
	#reset_chunks()
	pass
