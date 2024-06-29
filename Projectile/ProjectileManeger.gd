extends Area3D

var bullets = []
var delete= []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	
	if bullets:
		var y= 0
		for i in bullets:
			if i.timer >= 5:
				delete.append(i)
				continue
			i.transform.origin += i.direction * i.speed
			RenderingServer.instance_set_transform(i.shape,i.transform)
			PhysicsServer3D.area_set_shape_transform(self,y,i.transform)
			i.timer += delta
			y += 1
	if delete:
		for i in delete:
			RenderingServer.free_rid(i.shape)
			PhysicsServer3D.free_rid(i.coll)
			bullets.erase(i)
		delete.clear()


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	delete.append(bullets[local_shape_index])
