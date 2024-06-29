extends RigidBody3D

@onready var play = $AnimationPlayer
@onready var ray = $RayCast3D
@export var direction= Vector3()
var time = 0

func _ready():
	play.play("base")
	apply_central_force(direction * 8000)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if ray.is_colliding():
		play.play("explode")
		linear_velocity = Vector3.ZERO
	
	
	time += delta
	if time > 2:
		play.play("explode")
	




func _on_animation_player_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()
		


func _on_damage_body_entered(body):
	
	if body.has_method("take_damage"):
		body.take_damage(50)


func _on_explosion_body_entered(body):
	pass
	#play.play("explode")
	#linear_velocity = Vector3.ZERO


func _on_cuting_body_entered(body):
	if body.has_method("get_cuted"):
		body.get_cuted()
