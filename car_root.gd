extends Node3D

@onready var car_mesh: MeshInstance3D = $Car
@onready var cam: Camera3D = $CarCamera

var speed := 24.0
var turn_speed := 2.0

func _ready():
	print("🚗 CarRoot ready (controls + camera active)!")
	cam.current = true  # Force camera active

func _process(delta):
	# --- TURNING ---
	if Input.is_action_pressed("a") or Input.is_action_pressed("ui_left"):
		rotation.y += turn_speed * delta
	if Input.is_action_pressed("d") or Input.is_action_pressed("ui_right"):
		rotation.y -= turn_speed * delta

	# --- MOVEMENT ---
	var forward = -transform.basis.z.normalized()
	var move = Vector3.ZERO

	if Input.is_action_pressed("w") or Input.is_action_pressed("ui_up"):
		move += forward * speed * delta
	if Input.is_action_pressed("s") or Input.is_action_pressed("ui_down"):
		move -= forward * (speed * 0.6) * delta

	global_position += move
