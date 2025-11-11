extends Camera3D

@onready var road = $"../Path3D"   # adjust path if your road is in another node
@export var distance_from_road := 15.0   # how far back the camera sits
@export var height := 8.0                # how high above the road
@export var smooth_speed := 5.0

func _ready():
	print("🎥 Close-up camera active")
	current = true
	fov = 80.0

func _process(delta):
	if road and road.curve.get_point_count() > 0:
		# Follow the first segment of the road closely
		var road_start = road.curve.get_point_position(0)
		var road_next = road.curve.get_point_position(1)
		var direction = (road_next - road_start).normalized()

		var desired_position = road_start - direction * distance_from_road
		desired_position.y += height

		global_position = global_position.lerp(desired_position, delta * smooth_speed)
		look_at(road_start + Vector3(0, 3, 0), Vector3.UP)
