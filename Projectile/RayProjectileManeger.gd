extends Area3D

var bullets = []
var delete= []



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	
	if bullets:
		
		for bullet:Projectile in bullets:
			
			var bullet_position = bullet.transform.origin
			var bullet_direction = bullet.transform.basis.y
			var space_state = get_world_3d().direct_space_state
			var quere = PhysicsRayQueryParameters3D.create(bullet_position - bullet_direction*bullet.speed*2,bullet_position + bullet_direction*bullet.speed)
			quere.collide_with_areas = true
			quere.hit_from_inside = false
			var result : Dictionary = space_state.intersect_ray(quere)
			
			if result:
				if result.collider is Area3D:
					var ow : Node3D = result.collider.owner
					if !ow.is_in_group(bullet.owner):
						delete.append(bullet)
						result.collider.owner.takeDamage(bullet.damage)
				elif result.normal.dot(-bullet_direction)<0.25:
					bullet.transform.basis.y = bullet_direction.slide(result.normal)
				else :
					delete.append(bullet)

			if bullet.time > 2:
				delete.append(bullet)
			
			
			bullet.transform.origin += bullet_direction * bullet.speed
			bullet.speed += delta
			RenderingServer.instance_set_transform(bullet.instance,bullet.transform)
			bullet.time += delta * bullet.accel
	
	
	
	if delete:
		for bullet : Projectile in delete:
			RenderingServer.free_rid(bullet.instance)
			bullets.erase(bullet)
		delete.clear()
