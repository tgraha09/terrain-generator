extends Node

var global_data = []

func _ready():
	var global_data_node = get_node("res://demos/demo2/scripts/GlobalData.gd")
	global_data = global_data_node.get_heightmap_data()

func get_global_data():
	return global_data
