extends CharacterBody3D

const MAX_VELOCITY_AIR = 0.8
const MAX_VELOCITY_GROUND = 8.0
const MAX_ACCELERATION = 10 * MAX_VELOCITY_GROUND
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity") *2
const STOP_SPEED = 8.0
var JUMP_IMPULSE = sqrt(4 * GRAVITY * 0.85)

var friction = 4
var direction : Vector3
var wish_jump : bool


var xx : float = 0.0
var yy : float = 0.0

var maxHealth = 500
var Health = maxHealth

var killCount = 0

var pickedItem : RigidBody3D = null
@onready var pickRay = $head/RayCast3D
@onready var pickMarker = $head/Marker3D


@onready var model = $Rig
@onready var hands = $hands
@onready var camera = $head
@onready var gun = $hands/Weapon
@onready var gun2 = $hands/Weapon2
@onready var ray = $hands/RayCast3D
@onready var crosshair = $Control/CenterContainer
@onready var healthBar = $Control/VBoxContainer/HBoxContainer/ProgressBar
@onready var killLabel = $Control/VBoxContainer/HBoxContainer/killcount
@onready var bulletLabel = $Control/VBoxContainer/HBoxContainer/bullets
@onready var blood = $Control/TextureRect


func _ready():
	healthBar.max_value = maxHealth
	healthBar.value = maxHealth
	blood.texture.fill_to = Vector2.ONE
	gun.fired.connect(gunfire)
	gun2.fired.connect(gunfire)
	
func gunfire():
	bulletLabel.text = "bulletCount :" + str(gun.bulletCount)+"/"+str(gun.bulletCapacity)
	crosshair.scale = Vector2(3,3)

func _input(event):
	if event is InputEventJoypadMotion:
		var x:float = event.relative.y * get_process_delta_time() * 0.5
		var y:float = event.relative.x * get_process_delta_time() * 0.5
		
		xx -= x
		xx = clamp(xx,-PI/2,PI/2)
		yy -= y
		
		camera.quaternion = Quaternion(Vector3.UP,yy)*Quaternion(Vector3.RIGHT,xx)
		model.quaternion =  Quaternion(Vector3.UP,yy)
	
	if Input.is_action_pressed("pick"):
		if pickedItem != null:
			#pickedItem.apply_force(-1000*model.global_basis.z)
			pickedItem = null
		elif pickRay.is_colliding():
			if pickRay.get_collider() is RigidBody3D:
				pickedItem = pickRay.get_collider()
func _process(_delta):
	
	if pickedItem != null:
		var a = pickMarker.global_position
		var b = pickedItem.global_position
		pickedItem.linear_velocity = (a-b)*8+ velocity
	
	var tr = hands.global_transform.translated_local(Vector3(0.5,-0.25,-1.25))
	var tr2 = hands.global_transform.translated_local(Vector3(-0.5,-0.25,-1.25))
	
	gun.global_transform = tr
	gun2.global_transform = tr2
	
	hands.quaternion = hands.quaternion.slerp(camera.quaternion.normalized(),_delta*10)
	var point : Vector3 = Vector3.ZERO
	if ray.is_colliding():
		point = ray.get_collision_point()
	else :
		point = camera.to_global(Vector3.FORWARD * 100)
	
	#gun.look_at(point)
	#gun2.look_at(point)
	
	if Input.is_action_pressed("fire"):
			gun.fire()
			gun2.fire()
	
	crosshair.scale = crosshair.scale.lerp(Vector2(1,1),_delta*10)
	
	
	process_input()
	process_movement(_delta)
	



func process_input():
	direction = Vector3()
	
	
	if Input.is_action_pressed("forward"):
		direction -= model.global_basis.z
	elif Input.is_action_pressed("backward"):
		direction += model.global_basis.z
	if Input.is_action_pressed("left"):
		direction -= model.global_basis.x
	elif Input.is_action_pressed("right"):
		direction += model.global_basis.x
	
	
	# Jumping
	wish_jump = Input.is_action_just_pressed("jump")

func process_movement(delta):
	# Get the normalized input direction so that we don't move faster on diagonals
	var wish_dir = direction.normalized()

	if is_on_floor():
		# If wish_jump is true then we won't apply any friction and allow the 
		# player to jump instantly, this gives us a single frame where we can 
		# perfectly bunny hop
		if wish_jump:
			velocity.y = JUMP_IMPULSE
			# Update velocity as if we are in the air
			velocity = update_velocity_air(wish_dir, delta)
			wish_jump = false
		else:
			velocity = update_velocity_ground(wish_dir, delta)
	else:
		# Only apply gravity while in the air
		velocity.y -= GRAVITY * delta
		velocity = update_velocity_air(wish_dir, delta)
	# Move the player once velocity has been calculated
	
	killLabel.text = "killCount :" + str(killCount)
	
	healthBar.value = lerpf(healthBar.value,Health,delta*10)
	var b =  Vector2.ONE + Vector2.ONE * Health/maxHealth
	blood.texture.fill_to = blood.texture.fill_to.lerp(b,delta*2)
	move_and_slide()
 


func accelerate(wish_dir: Vector3, max_velocity: float, delta):
	# Get our current speed as a projection of velocity onto the wish_dir
	var current_speed = velocity.dot(wish_dir)
	# How much we accelerate is the difference between the max speed and the current speed
	# clamped to be between 0 and MAX_ACCELERATION which is intended to stop you from going too fast
	var add_speed = clamp(max_velocity - current_speed, 0, MAX_ACCELERATION * delta)
	
	return velocity + add_speed * wish_dir
	
func update_velocity_ground(wish_dir: Vector3, delta):
	# Apply friction when on the ground and then accelerate
	var speed = velocity.length()
	
	if speed != 0:
		var control = max(STOP_SPEED, speed)
		var drop = control * friction * delta
		
		# Scale the velocity based on friction
		velocity *= max(speed - drop, 0) / speed
	
	return accelerate(wish_dir, MAX_VELOCITY_GROUND, delta)
	
func update_velocity_air(wish_dir: Vector3, delta):
	# Do not apply any friction
	return accelerate(wish_dir, MAX_VELOCITY_AIR, delta)
 


func takeDamage(damage: float):
	Health -= damage
	Health = clamp(Health,0,maxHealth)
	if Health == 0: queue_free()
	blood.texture.fill_to = Vector2.ONE





func _on_area_3d_body_entered(body):
	if(body is RigidBody3D and body.is_in_group("health") and Health != maxHealth):
		Health += 10
		Health = clamp(Health,0,maxHealth)
		body.queue_free()
	if(body is RigidBody3D and body.is_in_group("bullet")):
		gun.bulletCapacity += 30
		gun2.bulletCapacity += 30
		body.queue_free()
