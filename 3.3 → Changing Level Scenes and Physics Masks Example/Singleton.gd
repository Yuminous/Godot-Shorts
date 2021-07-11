extends Spatial

onready var menu = $Label
onready var player = $KinematicBody
onready var player_head = $KinematicBody/Spatial
onready var player_body = $KinematicBody/MeshInstance
onready var camera = $KinematicBody/Spatial/Camera

onready var world1 = $Spatial
onready var world2 = $Spatial1
onready var sprite = $Sprite3D
onready var label = $Label2

var scene_counter = 0
var mask_reset = false

var gravity = true
var pause = true
var tps = false

var vertical_movement = 0
var speed_multiplier = 1
var terminal_velocity = -100


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
		
	# # # ——— SECTION FOR CHANGING "WORLDS" (below) ——— # # #
	
	if Input.is_action_just_pressed("change_world"):
		if scene_counter == 0:
			scene_counter += 1
			label.set_self_modulate(Color(1,1,1,1))
			world2 = load("res://Spatial1.tscn").instance()
			add_child(world2)
			world1.queue_free()
		elif scene_counter == 1:
			scene_counter += 1
			label.set_self_modulate(Color(1,1,1,1))
			world1 = load("res://Spatial2.tscn").instance()
			add_child(world1)
			world2.queue_free()
		elif scene_counter == 2:
			scene_counter += 1
			label.set_self_modulate(Color(1,1,1,1))
			world2 = load("res://Spatial3.tscn").instance()
			add_child(world2)
			world1.queue_free()
		elif scene_counter == 3:
			scene_counter = 0
			label.set_self_modulate(Color(1,1,1,1))
			world1 = load("res://Spatial0.tscn").instance()
			add_child(world1)
			world2.queue_free()
			
	# # # ——— SECTION FOR CHANGING "WORLDS" (above) ——— # # #
	
	label.set_self_modulate(Color(1,1,1,label.self_modulate.a-0.01))
	
	# # # ——— SECTION FOR PHYSICS MASKS (below) ——— # # #
	
	if Input.is_action_just_pressed("set_physics_mask"):
		if mask_reset == true:
			sprite.hide()
			player.set_collision_mask_bit(1, true)
			player.set_collision_mask_bit(2, true)
			mask_reset = false
		elif player.get_collision_mask_bit(1) == true:
			sprite.show()
			sprite.translation.z = 10.75
			player.set_collision_mask_bit(1, false)
			player.set_collision_mask_bit(2, true)
		else:
			sprite.translation.z = 17.5
			player.set_collision_mask_bit(1, true)
			player.set_collision_mask_bit(2, false)
			mask_reset = true
	
	# # # ——— SECTION FOR PHYSICS MASKS (above) ——— # # #
	
	
	if gravity == true:
		player.move_and_slide(Vector3(0, max(vertical_movement, terminal_velocity), 0), Vector3.UP)
	if player.is_on_floor() == true or player.is_on_wall() == true:
		vertical_movement = 0
		terminal_velocity = -100
		if Input.is_action_pressed("sprint"):
			speed_multiplier = 2
		if Input.is_action_just_pressed("walk"):
			speed_multiplier = 0.5
	else:
		vertical_movement -= 20 * delta * 1.5
		if Input.is_action_pressed("sprint"):
			terminal_velocity = -2
			vertical_movement = -2
	if Input.is_action_pressed("forward"):
		player.move_and_slide(Vector3(0, 0, -11 * speed_multiplier).rotated(Vector3.UP, player.rotation.y), Vector3.UP, true)
	if Input.is_action_pressed("back"):
		player.move_and_slide(Vector3(0, 0, 11 * speed_multiplier).rotated(Vector3.UP, player.rotation.y), Vector3.UP, true)
	if Input.is_action_pressed("left"):
		player.move_and_slide(Vector3(-11 * speed_multiplier, 0, 0).rotated(Vector3.UP, player.rotation.y), Vector3.UP, true)
	if Input.is_action_pressed("right"):
		player.move_and_slide(Vector3(11 * speed_multiplier, 0, 0).rotated(Vector3.UP, player.rotation.y), Vector3.UP, true)
	if Input.is_action_just_released("sprint"):
		speed_multiplier = 1
		terminal_velocity = -100
	if Input.is_action_just_released("walk"):
		speed_multiplier = 1
	if Input.is_action_just_pressed("jump"):
		vertical_movement = 10
	if Input.is_action_pressed("fly"):
		gravity = false
		speed_multiplier = 1
		vertical_movement = 0
		var A = player_head.rotation_degrees.x / 3 
		if Input.is_action_pressed("sprint"):
			speed_multiplier = 2
			A = A * 1.5
		if Input.is_action_pressed("forward"):
			player.move_and_slide(Vector3(0, A, 0), Vector3.UP)
	elif Input.is_action_just_released("fly"):
		gravity = true
		speed_multiplier = 1
	if Input.is_action_just_pressed("camera"):
		if tps == true:
			player_body.hide()
			camera.set_translation(Vector3(0, 0.2, -0.4))
			camera.rotation_degrees.x = -0
			tps = false
		elif tps == false:
			player_body.show()
			camera.set_translation(Vector3(0, 0.2, 4.4))
			camera.rotation_degrees.x = -10
			tps = true


func _unhandled_input(event):
	if event is InputEventMouseMotion and pause == false:
		player.rotate_y(-event.relative.x/150)
		player_head.rotation_degrees.x = clamp(player_head.rotation_degrees.x - event.relative.y/5, -70, 95)
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
