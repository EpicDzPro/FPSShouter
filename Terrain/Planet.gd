extends StaticBody3D

var chunk_size = 16
var size = 1
var chunks = {}





# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(-size,size+1):
		for y in range(-size,size+1):
			for z in range(-size,size+1):
				var chunk = MeshInstance3D.new()
				chunk.mesh = SphereMesh.new()
				chunk.position = Vector3(x,y,z) * chunk_size
				chunks[Vector3(x,y,z)] = chunk
				add_child(chunk)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
