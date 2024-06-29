extends CSGMesh3D

#var multi = MultiMesh.new()
var rs = RenderingServer
@export var m : Mesh
# Called when the node enters the scene tree for the first time.
func _ready():
	var multimesh = rs.multimesh_create()
	rs.multimesh_set_mesh(multimesh,m)
	rs.multimesh_allocate_data(multimesh,1000,RenderingServer.MULTIMESH_TRANSFORM_3D)
	
	var index = 0
	for x in range(-100,101):
		for z in range(-100,101):
			var y = 0
			
			var state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(Vector3(x,10,z),Vector3(x,-10,z))
			var result = state.intersect_ray(query)
			
			
			
			index += 1
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
