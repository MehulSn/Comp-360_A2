extends Node3D

func _ready():
	randomize()

	# === 1. Terrain Noise ===
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.08
	noise.fractal_octaves = 4  # 🔹 Added for smoother, natural terrain

	var sand_noise = FastNoiseLite.new()
	sand_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	sand_noise.frequency = 0.1

	# === 2. Mesh Generation ===
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var size = 200   
	var step = 1.0
	var height = 12.0

	for x in range(size):
		for z in range(size):
			var h1 = noise.get_noise_2d(x, z) * height
			var h2 = noise.get_noise_2d(x + 1, z) * height
			var h3 = noise.get_noise_2d(x, z + 1) * height
			var h4 = noise.get_noise_2d(x + 1, z + 1) * height

			var v1 = Vector3(x * step, h1, z * step)
			var v2 = Vector3((x + 1) * step, h2, z * step)
			var v3 = Vector3(x * step, h3, (z + 1) * step)
			var v4 = Vector3((x + 1) * step, h4, (z + 1) * step)

			st.set_uv(Vector2(x / float(size), z / float(size))); st.add_vertex(v1)
			st.set_uv(Vector2((x + 1) / float(size), z / float(size))); st.add_vertex(v2)
			st.set_uv(Vector2(x / float(size), (z + 1) / float(size))); st.add_vertex(v3)
			st.set_uv(Vector2((x + 1) / float(size), z / float(size))); st.add_vertex(v2)
			st.set_uv(Vector2((x + 1) / float(size), (z + 1) / float(size))); st.add_vertex(v4)
			st.set_uv(Vector2(x / float(size), (z + 1) / float(size))); st.add_vertex(v3)

	st.generate_normals()
	var mesh = st.commit()

	# === 3. Texture (white hills, no color change) ===
	var img = Image.create(size + 1, size + 1, false, Image.FORMAT_RGB8)
	for x in range(size + 1):
		for y in range(size + 1):
			var n = (noise.get_noise_2d(x, y) + 1.0) / 2.0
			var s = (sand_noise.get_noise_2d(x * 5.0, y * 5.0) + 1.0) / 2.0
			var mix = clamp(n * 0.8 + s * 0.2, 0.0, 1.0)
			img.set_pixel(x, y, Color(mix, mix, mix))
	img.save_png("user://heightmap.png") 
	var tex = ImageTexture.create_from_image(img)

	var mat = StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.albedo_color = Color(1.8, 1.8, 1.8)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.roughness = 0.25
	mat.specular = 0.3

	var terrain = MeshInstance3D.new()
	terrain.mesh = mesh
	terrain.material_override = mat
	terrain.position = Vector3(-size * 1.5, -3, -size * 0.8)
	terrain.scale = Vector3(4.0, 1.0, 4.0)
	add_child(terrain)

	# === 4. Lighting ===
	var sun_light = DirectionalLight3D.new()
	sun_light.rotation_degrees = Vector3(-40, 45, 0)
	sun_light.light_energy = 3.5
	sun_light.shadow_enabled = true
	add_child(sun_light)

	# === 5. Camera ===
	var cam = Camera3D.new()
	cam.position = Vector3(0, 45, 100)
	cam.rotation_degrees = Vector3(-20, 0, 0)
	cam.current = true
	add_child(cam)

	# === 6. Environment + Sky ===
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.68, 0.75, 0.9)
	sky_mat.sky_horizon_color = Color(0.9, 0.85, 0.75)
	sky_mat.sky_curve = 0.45
	sky_mat.energy_multiplier = 1.2
	sky.sky_material = sky_mat
	env.sky = sky

	env.ambient_light_color = Color(1, 1, 1)
	env.ambient_light_energy = 1.4
	env.glow_enabled = true
	env.glow_intensity = 0.8  # adds soft bloom around the sun
	world_env.environment = env
	add_child(world_env)

	# === 7. Cloud Layer ===
	var cloud_parent := Node3D.new()
	add_child(cloud_parent)

	for i in range(300):
		var cloud := MeshInstance3D.new()
		var cloud_mesh := SphereMesh.new()
		cloud_mesh.radius = randf_range(4.0, 8.0)
		cloud.mesh = cloud_mesh

		var cloud_mat := StandardMaterial3D.new()
		cloud_mat.albedo_color = Color(1, 1, 1, 0.85)
		cloud_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cloud_mat.roughness = 1.0
		cloud_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cloud.material_override = cloud_mat

		cloud.position = Vector3(randf_range(-250, 250), randf_range(60, 85), randf_range(-200, 200))
		cloud_parent.add_child(cloud)

		var tween := create_tween().set_loops()
		tween.tween_property(cloud, "position:x", cloud.position.x + randf_range(-40, 40), 100.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# === 8. Glowing Sun Between Clouds ===
	var sun_sphere := MeshInstance3D.new()
	var sun_mesh := SphereMesh.new()
	sun_mesh.radius = 10.0
	sun_sphere.mesh = sun_mesh

	var sun_mat := StandardMaterial3D.new()
	sun_mat.albedo_color = Color(1.0, 0.9, 0.7)
	sun_mat.emission_enabled = true
	sun_mat.emission = Color(1.0, 0.85, 0.6)
	sun_mat.emission_energy = 6.0
	sun_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sun_sphere.material_override = sun_mat

	sun_sphere.position = Vector3(0, 75, -150)
	add_child(sun_sphere)

	# === 9. Rain Effect (Gentle and Visible) ===
	var rain := GPUParticles3D.new()
	rain.amount = 2500
	rain.lifetime = 5.0
	rain.preprocess = 2.0
	rain.one_shot = false
	rain.explosiveness = 0.0

	var rain_process := ParticleProcessMaterial.new()
	rain_process.gravity = Vector3(0, -20, 0)
	rain_process.direction = Vector3(0, -1, 0)
	rain_process.initial_velocity_min = 3.0
	rain_process.initial_velocity_max = 6.0
	rain_process.scale_min = 1.0
	rain_process.scale_max = 1.8
	rain.process_material = rain_process

	var rain_mesh := QuadMesh.new()
	rain_mesh.size = Vector2(0.15, 1.0)
	rain.draw_pass_1 = rain_mesh

	var rain_mat := StandardMaterial3D.new()
	rain_mat.albedo_color = Color(0.85, 0.9, 1.0, 0.8)
	rain_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rain_mat.emission_enabled = true
	rain_mat.emission = Color(0.8, 0.9, 1.0)
	rain_mat.emission_energy = 0.6
	rain_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rain.material_override = rain_mat

	rain.position = Vector3(0, 90, 0)
	rain.scale = Vector3(14, 1, 14)
	rain.emitting = true
	add_child(rain)

	# === 10. Red Flag on Tallest Hill ===
	var highest_y := -9999.0
	var highest_pos := Vector3()

	for x in range(size):
		for z in range(size):
			var h = noise.get_noise_2d(x, z) * height
			if h > highest_y:
				highest_y = h
				highest_pos = Vector3(x * step, h, z * step)

	var flag := MeshInstance3D.new()
	var pole := CylinderMesh.new()
	pole.top_radius = 0.05
	pole.bottom_radius = 0.1
	pole.height = 2.5
	flag.mesh = pole

	var flag_mat := StandardMaterial3D.new()
	flag_mat.albedo_color = Color(1.0, 0.1, 0.1)
	flag.material_override = flag_mat
	flag.position = highest_pos + Vector3(0, 3, 0)
	add_child(flag)

	print("🏔 Flag placed on tallest mountain:", highest_pos)
	print("✅ Landscape generated successfully!")
