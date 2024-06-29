extends Node3D

signal  fired
var shoot = true
@onready var player= $AnimationPlayer
@onready var start = $start
@onready var sound = $AudioStreamPlayer3D
@export var mesh: CapsuleMesh
@export var bulletCapacity : int = 300
@export var bulletCount : int = 30
@export var bulletSpeed : float = 1
@export var bulletAccel : float = 1
@export var bulletDamage : float = 30
@export var fireSpeed : float = 0.25
@export var reloadTime : float = 1
@export var bullrtOwner : String = ""

@onready var maneger = get_node("/root/Node3D/Manger")
var recoil:float = 0

func _physics_process(delta):
	recoil = lerpf(recoil,0,delta*50)
	if bulletCount <= 0 and bulletCapacity > 0 and shoot:
		reload()

func reload():
	shoot = false
	player.play("reload",-1,reloadTime)
	await  get_tree().create_timer(reloadTime).timeout
	bulletCapacity -= 30
	bulletCount = 30
	shoot = true


func fire():
	if shoot == false or bulletCount <= 0: return
	shoot = false
	emit_signal("fired")
	sound.play()
	player.play("fire")
	var bullet : Projectile = Projectile.new()
	bullet.transform = start.global_transform
	bullet.speed = bulletSpeed
	bullet.accel = bulletAccel
	bullet.damage = bulletDamage
	bullet.owner = bullrtOwner
	
	bullet.instance = RenderingServer.instance_create()
	RenderingServer.instance_set_base(bullet.instance,mesh)
	RenderingServer.instance_set_scenario(bullet.instance,get_world_3d().scenario)
	RenderingServer.instance_set_transform(bullet.instance,bullet.transform)
	
	maneger.bullets.append(bullet)
	bulletCount -= 1 
	await  get_tree().create_timer(fireSpeed).timeout
	shoot = true

