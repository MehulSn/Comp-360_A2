extends MeshInstance3D

var speed := 45.0
var turn_speed := 4.0
@onready var headlight_l = $Headlight_L
@onready var headlight_r = $Headlight_R
var headlights_on = false

func _ready():
	print("🚗 Reversed-direction car ready!")

	# ✅ Keep the same perfect road position
	global_position = Vector3(3, 7, 90)

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

		# === SMALL WHITE LIGHT DOTS (visible bulbs) ===
	for i in [-1, 1]:
		var bulb = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.12
		sphere.height = 0.12
		bulb.mesh = sphere
		bulb.position = Vector3(i * 0.6, 0.3, -3.1)
		
		var bulb_mat = StandardMaterial3D.new()
		bulb_mat.albedo_color = Color(1, 1, 1)
		bulb_mat.emission_enabled = true
		bulb_mat.emission = Color(1, 1, 1)
		bulb_mat.emission_energy = 6.0  # makes it glow even in daylight
		bulb.set_surface_override_material(0, bulb_mat)
		
		add_child(bulb)

	for i in [-1, 1]:
		var light = OmniLight3D.new()
		light.light_energy = 12.0                     # 💡 much brighter
		light.light_color = Color(1, 1, 0.7)          # warm white
		light.omni_range = 80                         # huge range so it hits road
		light.shadow_enabled = true
		light.position = Vector3(i * 0.6, 0.3, -3.1)  # right in front corners
		add_child(light)
		
		
	# === REAR LIGHTS (red bulbs + glow) ===
	for i in [-1, 1]:
		var rear_bulb = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.12
		sphere.height = 0.12
		rear_bulb.mesh = sphere
		rear_bulb.position = Vector3(i * 0.8, 0.3, 2.1)   # ✅ symmetric to front
		var rear_bulb_mat = StandardMaterial3D.new()
		rear_bulb_mat.albedo_color = Color(1, 0, 0)
		rear_bulb_mat.emission_enabled = true
		rear_bulb_mat.emission = Color(1, 1,1)
		rear_bulb_mat.emission_energy = 6.0
		rear_bulb.set_surface_override_material(0, rear_bulb_mat)
		add_child(rear_bulb)
		# === REAR LIGHTS ===
	for i in [-1, 1]:
		var rear_light = OmniLight3D.new()
		rear_light.light_energy = 9.0                 
		rear_light.light_color = Color(1, 1, 1)
		rear_light.omni_range = 60
		rear_light.shadow_enabled = true
		rear_light.position = Vector3(i * 0.8, 0.3, 2.1)
		add_child(rear_light)
	for i in [-1, 1]:
		var lower_bulb = MeshInstance3D.new()
		var sphere2 = SphereMesh.new()
		sphere2.radius = 0.12
		sphere2.height = 0.12
		lower_bulb.mesh = sphere2
		lower_bulb.position = Vector3(i * 0.8, -0.25, 2.1)   # 🔽 lower by 0.25 on Y
		var lower_mat = StandardMaterial3D.new()
		lower_mat.albedo_color = Color(1, 0, 0)
		lower_mat.emission_enabled = true
		lower_mat.emission = Color(1, 1,1)
		lower_mat.emission_energy = 6.0
		lower_bulb.set_surface_override_material(0, lower_mat)
		add_child(lower_bulb)

	for i in [-1, 1]:
		var lower_light = OmniLight3D.new()
		lower_light.light_energy = 9.0
		lower_light.light_color = Color(1, 1,1)
		lower_light.omni_range = 60
		lower_light.shadow_enabled = true
		lower_light.position = Vector3(i * 0.8, -0.25, 2.1)  # 🔽 lower match
		add_child(lower_light)
		
		# === Headlights ===
		# === HEADLIGHTS (REAL BEAMS) ===
	# === HEADLIGHTS (REAL BEAMS) ===
	headlight_l = SpotLight3D.new()
	headlight_l.light_energy = 9.0
	headlight_l.spot_angle = 65
	headlight_l.spot_range = 85
	headlight_l.position = Vector3(-1.8, 1.6, 3.6)
	headlight_l.rotation_degrees = Vector3(-8, 0, 0)
	headlight_l.visible = false
	add_child(headlight_l)

	headlight_r = SpotLight3D.new()
	headlight_r.light_energy = 9.0
	headlight_r.spot_angle = 65
	headlight_r.spot_range = 85
	headlight_r.position = Vector3(0.8, 0.5, 3.1)
	headlight_r.rotation_degrees = Vector3(-8, 0, 0)
	headlight_r.visible = false
	add_child(headlight_r)


# === MOVEMENT ===
func _process(delta):
	# === 1️⃣ TURNING ===
	if Input.is_action_pressed("a") or Input.is_action_pressed("ui_left"):
		rotation.y += turn_speed * delta
	if Input.is_action_pressed("d") or Input.is_action_pressed("ui_right"):
		rotation.y -= turn_speed * delta

	# === 2️⃣ MOVEMENT ===
	var forward = -transform.basis.z.normalized()
	var move = Vector3.ZERO

	if Input.is_action_pressed("w") or Input.is_action_pressed("ui_up"):
		move += forward * speed * delta
	if Input.is_action_pressed("s") or Input.is_action_pressed("ui_down"):
		move -= forward * (speed * 0.5) * delta

	global_position += move   # ✅ keeps your car visible & moving correctly

	# === 3️⃣ Y-HEIGHT CORRECTION (fake gravity but stable) ===
	if global_position.y > 7.5:
		global_position.y -= 2.0 * delta  # gently pull it down
	elif global_position.y < 7.0:
		global_position.y += 1.0 * delta  # stop from sinking

	# === 4️⃣ TILT EFFECT ===
	var target_tilt = 0.0
	if Input.is_action_pressed("w") or Input.is_action_pressed("ui_up"):
		target_tilt = -0.03
	elif Input.is_action_pressed("s") or Input.is_action_pressed("ui_down"):
		target_tilt = 0.03
	rotation.x = lerp(rotation.x, target_tilt, delta * 4.0)

	if Input.is_action_just_pressed("HeadlightToggle"):
		headlights_on = not headlights_on
		headlight_l.visible = headlights_on
		headlight_r.visible = headlights_on
		print("💡 Headlights:", headlights_on)
