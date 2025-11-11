extends MeshInstance3D

var speed := 24.0
var turn_speed := 2.0

func _ready():
	print("🚗 Reversed-direction car ready!")

	# ✅ Keep the same perfect road position
	global_position = Vector3(3, 38, 90)

	# === MAIN BODY ===
	var body = BoxMesh.new()
	body.size = Vector3(2, 1, 4)
	mesh = body
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.9, 0.05, 0.05)
	set_surface_override_material(0, body_mat)

	# === ROOF ===
	var roof = MeshInstance3D.new()
	var roof_mesh = BoxMesh.new()
	roof_mesh.size = Vector3(1.6, 0.8, 1.6)
	roof.mesh = roof_mesh
	roof.position = Vector3(0, 1.0, 0.5)  # 🔁 shifted backward slightly
	var roof_mat = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.1, 0.1, 0.12)
	roof.set_surface_override_material(0, roof_mat)
	add_child(roof)

	# === HOOD (now at BACK instead of FRONT) ===
	var hood = MeshInstance3D.new()
	var hood_mesh = BoxMesh.new()
	hood_mesh.size = Vector3(1.6, 0.5, 1.0)
	hood.mesh = hood_mesh
	hood.position = Vector3(0, 0.3, -2.5)  # 🔁 moved to back side
	var hood_mat = StandardMaterial3D.new()
	hood_mat.albedo_color = Color(0.8, 0.1, 0.1)
	hood.set_surface_override_material(0, hood_mat)
	add_child(hood)

	# === WHEELS ===
	for i in [-1, 1]:
		for j in [-1, 1]:
			var wheel = MeshInstance3D.new()
			var cyl = CylinderMesh.new()
			cyl.height = 0.4
			cyl.top_radius = 0.35
			cyl.bottom_radius = 0.35
			wheel.mesh = cyl
			wheel.rotation_degrees = Vector3(90, 0, 0)
			wheel.position = Vector3(i * 1.2, -0.7, j * 1.8)
			var wheel_mat = StandardMaterial3D.new()
			wheel_mat.albedo_color = Color(0.05, 0.05, 0.05)
			wheel.set_surface_override_material(0, wheel_mat)
			add_child(wheel)

	# === LIGHTS (now reversed) ===
	# Rear lights become front lights
	for i in [-1, 1]:
		var light = OmniLight3D.new()
		light.light_energy = 1.5
		light.light_color = Color(1, 1, 0.8)
		light.position = Vector3(i * 0.8, 0.4, -2.7)  # 🔁 moved to new front (back side)
		add_child(light)

	# New rear lights on opposite end
	for i in [-1, 1]:
		var rear_light = OmniLight3D.new()
		rear_light.light_energy = 1.0
		rear_light.light_color = Color(1, 0, 0)
		rear_light.position = Vector3(i * 0.8, 0.4, 2.2)
		add_child(rear_light)


# === MOVEMENT ===
func _process(delta):
	# Handle turning (rotation in Y)
	if Input.is_action_pressed("a") or Input.is_action_pressed("ui_left"):
		rotation.y += turn_speed * delta
	if Input.is_action_pressed("d") or Input.is_action_pressed("ui_right"):
		rotation.y -= turn_speed * delta

	# Calculate forward direction
	var forward = -transform.basis.z.normalized()  # 🔥 This is the correct visual forward axis

	var move = Vector3.ZERO

	# Move along car's facing direction
	if Input.is_action_pressed("w") or Input.is_action_pressed("ui_up"):
		move += forward * speed * delta     # Move forward (in visual front)
	if Input.is_action_pressed("s") or Input.is_action_pressed("ui_down"):
		move -= forward * (speed * 0.6) * delta  # Move backward

	# Apply translation
	global_position += move
