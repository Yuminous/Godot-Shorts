extends Spatial

onready var menu = $Label
onready var player = $KinematicBody
onready var player_head = $KinematicBody/Spatial
onready var camera = $KinematicBody/Spatial/Camera

var gravity = true
var pause = true
var tps = false

var vertical_movement = 0
var sprint_multiplier = 1
var freefall_multiplier = 1



func menu():
	if menu.visible == true:
		menu.hide()
		pause = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif menu.visible == false:
		menu.show()
		pause = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _physics_process(delta):
	if pause == true:
		return
		
	if gravity == true:
		player.move_and_slide(Vector3(0, vertical_movement, 0), Vector3.UP)
	if player.is_on_floor() == true:
		freefall_multiplier = 1
		if Input.is_action_pressed("sprint"):
			sprint_multiplier = 2
		if Input.is_action_just_pressed("jump"):
			vertical_movement = 7	
	else:
		vertical_movement -= 10 * delta * freefall_multiplier
		freefall_multiplier += delta * 3
		
	if Input.is_action_pressed("forward"):
		player.move_and_slide(Vector3(0, 0, -11 * sprint_multiplier).rotated(Vector3.UP, player.rotation.y), Vector3.UP, true)
	if Input.is_action_pressed("back"):
		player.move_and_slide(Vector3(0, 0, 11 * sprint_multiplier).rotated(Vector3.UP, player.rotation.y), Vector3.UP, true)
	if Input.is_action_pressed("left"):
		player.move_and_slide(Vector3(-11 * sprint_multiplier, 0, 0).rotated(Vector3.UP, player.rotation.y), Vector3.UP, true)
	if Input.is_action_pressed("right"):
		player.move_and_slide(Vector3(11 * sprint_multiplier, 0, 0).rotated(Vector3.UP, player.rotation.y), Vector3.UP, true)
	if Input.is_action_pressed("sprint"):
		freefall_multiplier = 0.2
	elif Input.is_action_just_released("sprint"):
		sprint_multiplier = 1
		freefall_multiplier = 1
		
	
	# the method of flight here below is very crude, based simply on the camera rotation, but it can be tuned better so that players don't notice or don't mind.
	# o método de voo aqui é muito rude, é simplesmente baseado na rotação da câmara, mas pode ser melhorado de modo a que os jogadores não se apercebam da diferença.
	
	if Input.is_action_pressed("fly"):
		gravity = false
		sprint_multiplier = 1
		freefall_multiplier = 1
		vertical_movement = 0
		var A = player_head.rotation_degrees.x / 3  # <<< flight up or down is based on camera rotation, finely tune this by changing the offset "/ 3"
		if Input.is_action_pressed("sprint"):
			sprint_multiplier = 2
			A = A * 1.5  # <<< climb rate is multiplied here while "sprinting" in the air to maintain flight attitude, again, modify the offset if need be
		
		
		if Input.is_action_pressed("forward"):
			player.move_and_slide(Vector3(0, A, 0), Vector3.UP)
	elif Input.is_action_just_released("fly"):
		gravity = true
		sprint_multiplier = 1
	if Input.is_action_just_pressed("camera"):
		if tps == true:
			camera.set_translation(Vector3(0, 0.2, -0.4))
			camera.rotation_degrees.x = -0
			tps = false
		elif tps == false:
			camera.set_translation(Vector3(0, 0.2, 4.4))
			camera.rotation_degrees.x = -10
			tps = true		



func _unhandled_input(event):
	if event is InputEventMouseMotion and pause == false:
		player.rotate_y(-event.relative.x/150)
		player_head.rotation_degrees.x = clamp(player_head.rotation_degrees.x - event.relative.y/5, -50, 90)
		
	if event.is_action_pressed("pause"):
		menu()



func _on_Button_pressed():
	get_tree().quit()
	
func _on_Button2_pressed():
	menu()

func _on_Button3_pressed():
	player.set_translation(Vector3(0, 0, 0))
	camera.set_translation(Vector3(0, 0.2, -0.4))
	camera.rotation_degrees.x = -0
	menu()
	
