extends RigidBody2D

var walled = Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	if(walled != Vector2.ZERO):
		set_axis_velocity(walled)

func _integrate_forces(s):
	var lFound=false
	var rFound=false
	var wall=Vector2.ZERO
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)
		# dot product at parallel = 1, at perpendicular = 0
		if not lFound and ci.dot(Vector2.RIGHT) > 0.9: #and contact.tag==immovable
			wall+=Vector2.LEFT
			lFound=true
		if not rFound and ci.dot(Vector2.LEFT) > 0.9:
			wall+=Vector2.RIGHT
			rFound=true
	walled=wall
	pass
