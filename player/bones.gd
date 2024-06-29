extends Node3D


@onready var fabrik : Fabrik = $fabrikLeft
@onready var skeleton= $Skeleton3D
var boneArray = [10,11,12]
@export var targetik :Node3D
@export var targetpole : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	fabrik.activate(boneArray,skeleton,targetik,targetpole)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
