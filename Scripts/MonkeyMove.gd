class_name Monkey
extends RigidBody2D

onready var info: RichTextLabel = $data

export var movementCurve: Curve
var maxSpeed = 100
var acceTimer = 0
var jumpTimer = 0
var input: keyInput = keyInput.new()
var grounded = false

class keyInput:
	var dirn: Vector2 = Vector2.ZERO
	var jump: bool = false
	var power: bool = false

func _ready():
	OS.set_window_size(Vector2(1600, 960))
	var ss=OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	OS.set_window_position(ss*0.5 - window_size*0.5)
	makeRays()
	#feetRays()
	pass

func _process(delta):
	get_input()
	pass
	
func _physics_process(delta):
	#MovementLoop(delta)
	pass

func _input(event):
	if(Input.is_key_pressed(KEY_R)):
		get_tree().reload_current_scene()

func get_input():
	var dirn: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left"):
		dirn.x-=1
	if Input.is_action_pressed("right"):
		dirn.x+=1
	input.dirn=dirn
	if Input.is_action_pressed("jump"):
		input.jump=true
	else:
		input.jump=false
	if Input.is_action_pressed("power"):
		input.power=true
	else:
		input.power=false
	pass

func MovementLoop(delta):
	# UPWARDS IS NEGATIVE
	if(input.jump and grounded):
		set_axis_velocity(Vector2(0,-150))
		input.jump=false
	elif(input.power):
		#pass
		set_axis_velocity(Vector2(0,100))
	
	if(input.dirn==Vector2.ZERO):
		if(linear_velocity.x == 0):
			acceTimer=0
		else:
			var dirn=Vector2(sign(linear_velocity.x),0)
			var maxSpeedTime=movementCurve.get_point_position(2).x
			if(acceTimer<maxSpeedTime):
				acceTimer=maxSpeedTime
			if(grounded):
				acceTimer+=delta
			else: # slow down slower in the air
				acceTimer+=(delta/3.0)
			if(acceTimer>=1):
				acceTimer=1
			var speed=movementCurve.interpolate(acceTimer)*maxSpeed
			var toSet=speed*dirn+Vector2(0,linear_velocity.y)
			set_linear_velocity(toSet)
		pass
	else:
		acceTimer+=delta
		var maxSpeedTime=movementCurve.get_point_position(1).x
		if(acceTimer>maxSpeedTime):
			acceTimer=maxSpeedTime
		var speed=movementCurve.interpolate(acceTimer)*maxSpeed
		var toSet=speed*input.dirn+Vector2(0,linear_velocity.y)
		set_linear_velocity(toSet)
	
	pass

# https://docs.godotengine.org/en/stable/classes/class_rigidbody2d.html?#class-rigidbody2d-method-integrate-forces
# its like _physics_process, but for directly messing with rigidbodies

func _integrate_forces(s):
	var delta = get_physics_process_delta_time() 
	MovementLoop(delta)
	
	info.text=str(s.get_contact_count())
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)
		# dot product at parallel = 1, at perpendicular = 0
		if ci.dot(Vector2(0, -1)) > 0.6:
			grounded=true
			return
	grounded=false
	pass
	
func makeRays():
	var length=32
	var diff=length/8.0
	var rotation=0
	var dirns=[Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]
	for dirn in dirns:
		var offset=-length+diff
		while(offset<length):
			var cs=CollisionShape2D.new()
			var ray=RayShape2D.new()
			add_child((cs))
			ray.length=length
			cs.rotation_degrees=rotation
			cs.shape=ray
			cs.position=dirn*offset
			offset+=diff
		rotation+=90
	pass
	
func feetRays():
	var length=32
	var diff=length/4
	var offset=-length+diff
	while(offset<length):
		var cs=CollisionShape2D.new()
		var ray=RayShape2D.new()
		add_child((cs))
		ray.length=length
		cs.shape=ray
		cs.position=Vector2.LEFT*offset
		offset+=diff
	return
	var left=CollisionShape2D.new()
	left.name="LEFT"
	var ball=CircleShape2D.new()
	ball.radius=diff/2.0
	add_child(left)
	left.shape=ball
	var center=offset-(diff/2.0)
	left.position=Vector2(-center,center)
	print(left.position)
