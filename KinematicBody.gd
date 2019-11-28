extends KinematicBody

onready var camera = $Pivot/Camera
var gravity = -30
var max_ground_movement = 8
var max_flight_movement = 30
var mouse_sensitivity = .002 #radians per pixel
var jump_speed = 12
var jump = false
var launch = false
var launch_speed = 400
var launch_direction = Vector3()
var velocity = Vector3()
var resistance = -5

func get_input():
	jump = false
	if Input.is_action_just_pressed("jump"):
		jump = true
	var input_dir = Vector3()
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	if not is_on_floor() and Input.is_action_just_pressed("jump"):
		launch = true
		launch_direction = -camera.global_transform.basis.z
	return input_dir
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)

func _physics_process(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input()*max_ground_movement
	var desired_flight_velocity = get_input()*max_flight_movement
	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	
	if launch:
		var wind = get_node("Pivot/Camera/Particles")
		if not is_on_floor():
			velocity.x = desired_flight_velocity.x
			velocity.z = desired_flight_velocity.z
			if(launch_speed > 0):
				velocity = -camera.global_transform.basis.z * launch_speed
				launch_speed -= max(launch_speed/17, .5)
			if(launch_speed > 200):
				wind.emitting = true
			else: 
				wind.emitting = false
				
		else: 
			wind.emitting = false
			launch = false
			launch_speed = 400
	
	var collision = move_and_collide(velocity, true, true, true)
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("Goal"):
			var scene = get_tree().get_current_scene()
			if scene.is_in_group("Level 1"):
				get_tree().change_scene("Scenes/Level2.tscn")
			if scene.is_in_group("Level 2"):
				get_tree().change_scene("Scenes/Level3.tscn")
			if scene.is_in_group("Level 3"):
				get_tree().change_scene("Scenes/End.tscn")
		if body.is_in_group("Lava"):
			get_tree().reload_current_scene()
	if jump and is_on_floor():
		velocity.y = jump_speed
	
	
	
	