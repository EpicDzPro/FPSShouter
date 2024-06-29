extends CharacterBody3D

@export var lootTable : Array[PackedScene]
var player : CharacterBody3D = null
@onready var gun = $Node/Weapon
@onready var healthBar = $Node/Sprite3D/SubViewport/ProgressBar
@onready var v1 = $Node
var maxHealth = 200
var Health = maxHealth

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar.max_value = maxHealth
	healthBar.value = Health
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var direction= Vector3.ZERO
	if player != null:
		v1.look_at(player.global_position)
		#gun.look_at(player.global_position)
		
		if(global_position.distance_to(player.global_position)>4):
			direction = global_position.direction_to(player.global_position)
		else:
			gun.fire()
	healthBar.value = lerpf(healthBar.value,Health,_delta*20)
	velocity = direction * 140 * _delta
	move_and_slide()

func takeDamage(damage: float):
	Health -= damage
	Health = clamp(Health,0,maxHealth)
	if Health == 0:
		player.killCount += 1
		var healthBox = lootTable.pick_random().instantiate()
		get_parent().add_child(healthBox)
		healthBox.position = global_position
		get_parent().trs.erase(self)
		queue_free()
