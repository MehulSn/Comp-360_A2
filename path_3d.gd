extends Path3D

@export var segment_count := 20
@export var segment_length := 10.0
@export var road_width := 14.0
@export var y_height := 37.0
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
	st.index()
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

	# === 3️⃣ Add flag ===
	var flag_base_pos = curve.get_point_position(segment_count - 1)

	# 🪜 Pole
	var pole = MeshInstance3D.new()
	var pole_mesh = CylinderMesh.new()
	pole_mesh.height = 12.0
	pole_mesh.top_radius = 0.15
	pole_mesh.bottom_radius = 0.15
	pole.mesh = pole_mesh
	pole.position = flag_base_pos + Vector3(0, 6, 0)

	var pole_mat = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.2, 0.2, 0.2)
	pole.set_surface_override_material(0, pole_mat)
	add_child(pole)

	# 🚩 Flag (unshaded, glowing, always visible)
	flag_mesh_instance = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(5, 3)
	flag_mesh_instance.mesh = plane
	flag_mesh_instance.position = flag_base_pos + Vector3(2.5, 9.0, 0)
	flag_mesh_instance.rotation_degrees = Vector3(0, -90, 0)

	var flag_mat = StandardMaterial3D.new()
	flag_mat.albedo_color = Color(1, 0, 0)
	flag_mat.emission_enabled = true
	flag_mat.emission = Color(1, 0, 0)
	flag_mat.emission_energy = 4.0
	flag_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	flag_mat.unshaded = true                  # ✅ Ignore scene light & fog
	flag_mat.disable_ambient_light = true     # ✅ Keep it pure red
	flag_mesh_instance.set_surface_override_material(0, flag_mat)
	add_child(flag_mesh_instance)

	print("🏁 Bright red flag added — unshaded & visible in all lighting!")


func _process(delta):
	# 🌬 Simple waving animation
	if flag_mesh_instance:
		var t = Time.get_ticks_msec() / 1000.0
		flag_mesh_instance.rotation_degrees.z = sin(t * 3.0) * 5.0
