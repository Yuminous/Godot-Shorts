extends Node

var pause := true

var camera
var camera_dolly
var pivot_point
var turret_pivot
var turret
var tank
var menu

var drive_acceleration: int = 4500
var sensitivity: int = 1000
var slew_acceleration: float = 0.01
var turret_slew_acceleration: float = 0.04
var max_slew: float = 1



func _ready() -> void:
	camera = $WorldEnvironment/Tank/Dolly/Cam
	camera_dolly = $WorldEnvironment/Tank/Dolly
	pivot_point = $WorldEnvironment/Tank/RigidBody/Pivot
	turret_pivot = $WorldEnvironment/Tank/GunTurret/Pivot
	turret = $WorldEnvironment/Tank/GunTurret
	tank = $WorldEnvironment/Tank/RigidBody
	menu = $Menu



func _physics_process(delta) -> void:
	if pause:
		menu.modulate.a = min(menu.modulate.a + 0.03, 1)
		return
	menu.modulate.a = max(menu.modulate.a - 0.1, 0)
	
	camera_dolly.translation = tank.translation + Vector3(0, 2, 0)
	turret.rotation.y = lerp_angle(turret.rotation.y, camera_dolly.rotation.y, turret_slew_acceleration)
	turret_pivot.global_transform[3] = pivot_point.global_transform[3]
	
	if Input.is_action_pressed("tank_drive"):
		tank.add_central_force(tank.get_global_transform().basis.z.normalized() * drive_acceleration)
	elif Input.is_action_pressed("tank_reverse"):
		tank.add_central_force(tank.get_global_transform().basis.z.normalized() * -drive_acceleration)
	if Input.is_action_pressed("tank_pivot_left"):
		tank.angular_velocity.y = min(tank.angular_velocity.y + slew_acceleration, max_slew)
	elif Input.is_action_pressed("tank_pivot_right"):
		tank.angular_velocity.y = max(tank.angular_velocity.y - slew_acceleration, -max_slew)



func _input(event) -> void:
	if event.is_action_pressed("pause_menu"):
		if pause:
			pause = false
			tank.set_mode(0)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			pause = true
			tank.set_mode(1)
	if pause:
		return
	
	if event is InputEventMouseMotion:
		camera_dolly.rotate_y(-event.relative.x/sensitivity)
		
	if event.is_action_pressed("camera_zoom_in"):
		camera.translation.z += 0.1
		camera.rotation.x -= 0.001
	elif event.is_action_pressed("camera_zoom_out"):
		camera.translation.z -= 0.1
		camera.rotation.x += 0.001
