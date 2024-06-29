extends Node3D

@export var playerScene : PackedScene
@export var turret : PackedScene
var allowed = true
var rnd = RandomNumberGenerator.new()
var player : CharacterBody3D = null
@onready var button = $Control/Button
var spawnTime = 1
var lasttr = Transform3D()
var trs = []



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	button.visible = player == null
	if(allowed and player != null and trs.size()<8):spawn()

func spawn():
	allowed = false
	var Turret = turret.instantiate()
	add_child(Turret)
	trs.append(Turret)
	rnd.randomize()
	var x = rnd.randi_range(-200,200)
	rnd.randomize()
	var z = rnd.randi_range(-200,200)
	Turret.position = Vector3(z,4,x)
	Turret.player = player
	await get_tree().create_timer(spawnTime).timeout
	allowed = true


func _on_button_pressed():
	player = playerScene.instantiate()
	add_child(player)
	player.global_position = Vector3(0,8,0)
	for tr in trs:
		tr.queue_free()
	trs.clear()
	
