extends Path3D

@export var segment_count := 60
@export var segment_length := 10.0
@export var road_width := 40.0
@export var y_height := 6.0
@export var curve_strength := 120.0
@export var z_offset := 200.0
@export var x_center := -110.0

var flag_mesh_instance: MeshInstance3D

func _ready():
	print("🛣 Building road with visible bright red flag...")

	# === 1️⃣ Create road path ===
	curve = Curve3D.new()
	for i in range(segment_count):
		var z = i * -segment_length + z_offset
		var x = sin(float(i) / 9.0) * curve_strength
		curve.add_point(Vector3(x + x_center, y_height, z))

	# === 2️⃣ Build road mesh ===
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var left_points = []
	var right_points = []

	for i in range(segment_count):
		var p = curve.get_point_position(i)
		if i < segment_count - 1:
			var next_p = curve.get_point_position(i + 1)
			var dir = (next_p - p).normalized()
			dir.y = 0
			var right = dir.cross(Vector3.UP).normalized() * (road_width * 0.5)
			left_points.append(p - right)
			right_points.append(p + right)

	for i in range(segment_count - 2):
		var v0 = left_points[i]
		var v1 = right_points[i]
		var v2 = left_points[i + 1]
		var v3 = right_points[i + 1]

		st.add_vertex(v0)
		st.add_vertex(v2)
		st.add_vertex(v1)
		st.add_vertex(v2)
		st.add_vertex(v3)
		st.add_vertex(v1)

	st.generate_normals()
	var mesh = st.commit()

	var road = MeshInstance3D.new()
	road.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.07, 0.07, 0.07)
	mat.roughness = 0.75
	mat.metallic = 0.25
	mat.specular = 0.4
	road.set_surface_override_material(0, mat)
	add_child(road)

	print("✅ Road built successfully.")

	# === ✅ Add collision so the car raycast can hit it ===
	var static_body = StaticBody3D.new()
	var collision = CollisionShape3D.new()
	collision.shape = mesh.create_trimesh_shape()
	static_body.add_child(collision)
	add_child(static_body)
	print("✅ Collision added for road.")

	
		# === 🚩 FLAG (perfectly aligned at road end) ===
		# === 🚩 FLAG + STICK (perfect alignment at road end) ===
	var flag_base_pos = curve.get_point_position(segment_count - 2)

	# === FLAG ===
	var flag_mesh = PlaneMesh.new()
	flag_mesh.size = Vector2(3,2)
	flag_mesh_instance = MeshInstance3D.new()
	flag_mesh_instance.mesh = flag_mesh

	# ✅ Slightly up and forward from road
	flag_mesh_instance.position = flag_base_pos + Vector3(0, 8.0, 8.0)
	flag_mesh_instance.rotation_degrees = Vector3(0, 180, 0)

	# === Material for glowing flag ===
	var flag_mat = StandardMaterial3D.new()
	flag_mat.albedo_color = Color(1, 0, 0)
	flag_mat.emission_enabled = true
	flag_mat.emission = Color(1, 0, 0)
	flag_mat.emission_energy = 4.0
	flag_mat.unshaded = true
	flag_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	flag_mesh_instance.set_surface_override_material(0, flag_mat)
	add_child(flag_mesh_instance)

	# === STICK (pole for the flag) ===
	var stick = MeshInstance3D.new()
	var stick_mesh = CylinderMesh.new()
	stick_mesh.height = 10.0      # how tall the pole is
	stick_mesh.top_radius = 0.15
	stick_mesh.bottom_radius = 0.15
	stick.mesh = stick_mesh

	# ✅ place it right under the flag
	stick.position = flag_base_pos + Vector3(0, 3.0, 8.0)

	# === Metal pole material ===
	var stick_mat = StandardMaterial3D.new()
	stick_mat.albedo_color = Color(0.2, 0.2, 0.2)   # dark metallic grey
	stick_mat.metallic = 0.8
	stick_mat.roughness = 0.2
	stick.set_surface_override_material(0, stick_mat)

	add_child(stick)

	print("🏁 Flag + Stick added neatly at:", flag_mesh_instance.global_position)
