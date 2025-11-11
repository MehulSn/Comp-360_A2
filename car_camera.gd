extends Camera3D

@export var target: Node3D        # drag your Car here in the Inspector
@export var follow_distance := 25.0
@export var height := 10.0
@export var smooth_speed := 6.0

func _ready() -> void:
	# Try to find the car automatically if not assigned
	if target == null and get_parent() and get_parent().has_node("Car"):
		target = get_parent().get_node("Car") as Node3D

	# Make sure THIS camera becomes the active one
	make_current()

	# Debug info
	var active_cam = get_viewport().get_camera_3d()
	if active_cam:
		print("🎥 Car-follow camera ready. target =", target)
		print("Active camera is:", active_cam.name)
	else:
		print("⚠️ No active camera detected!")

func _process(delta: float) -> void:
	# If another camera takes over, reclaim control
	if not is_current():
		make_current()

	if target:
		# Place the camera behind and above the car
		var desired = target.global_position + target.global_transform.basis.z * follow_distance
		desired.y += height

		# Smoothly move the camera
		global_position = global_position.lerp(desired, delta * smooth_speed)

		# Always look at the car slightly above its center
		look_at(target.global_position + Vector3(0, 2, 0), Vector3.UP)
