extends Node3D


@export var Chunk_Scene : PackedScene
@export var Fast_Noise : FastNoiseLite
@export var Viewer : RigidBody3D

@export var Terrain_Size = 128
@export var Terrain_Max_Height = 128
@export var Resolution = 8
@export var View_Distance = 8
@export var Thread_Count = 10

var Threads = []
var Terrain_Cordination = Vector2()
var Current_Cordination = Vector2()
var Viewer_Position = Vector2()
var Terrain_Chunks = {}
var Chunks_Visible = 0
var edit = []


func _ready():
	for i in Thread_Count:
		Threads.append(Thread.new())
	Viewer_Position = Vector2(Viewer.global_position.x,Viewer.global_position.z)
	generate_world()

func _physics_process(delta):
	Viewer_Position = Vector2(Viewer.global_position.x,Viewer.global_position.z)
	generate_world()
	
	for i in range(0,8):
		if edit.size() == 0 : break
		edit[0].generate_terrain()
		edit.erase(edit[0])

func generate_world():
	Current_Cordination.x = roundi(Viewer_Position.x / Terrain_Size)
	Current_Cordination.y = roundi(Viewer_Position.y / Terrain_Size)
	for x in range(-View_Distance,View_Distance + 1):
		for y in range(-View_Distance,View_Distance + 1):
			
			Terrain_Cordination.x = Current_Cordination.x + x
			Terrain_Cordination.y = Current_Cordination.y + y
			
			var Distance = Vector2()
			Distance.x = abs(x)
			Distance.y = abs(y)
			
			if !Terrain_Chunks.has(Terrain_Cordination):
				
				var Chunk = Chunk_Scene.instantiate()
				add_child(Chunk)
				Chunk.global_position = Vector3(Terrain_Cordination.x * Terrain_Size,0,Terrain_Cordination.y * Terrain_Size)
				Chunk.Terrain_Size = Terrain_Size
				Chunk.Terrain_Max_Height = Terrain_Max_Height
				Chunk.Resolution = Resolution
				Chunk.noise = Fast_Noise
				Terrain_Chunks[Terrain_Cordination] = Chunk
				
				edit.append(Chunk)
				
			else:
				if Distance.x >= View_Distance or Distance.y >= View_Distance:
					Terrain_Chunks[Terrain_Cordination].visible = false
					Terrain_Chunks[Terrain_Cordination].use_collision = false
				else:
					Terrain_Chunks[Terrain_Cordination].visible = true
					Terrain_Chunks[Terrain_Cordination].use_collision = true



