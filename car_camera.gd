extends Camera3D

@onready var car = $"../Car"
var follow_distance := 25.0
var height := 10.0
var smooth_speed := 4.0

func _ready():
	fov = 75.0
	far = 2000.0
	current = true
	print("🎥 Car Camera Active")

func _process(delta):
	if car:
		var desired_pos = car.global_position - car.global_transform.basis.z * follow_distance
		desired_pos.y += height
		global_position = global_position.lerp(desired_pos, delta * smooth_speed)
		look_at(car.global_position + Vector3(0, 2, 0), Vector3.UP)
