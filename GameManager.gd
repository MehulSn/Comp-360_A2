extends Node

@export var car_path: NodePath
@export var flag_path: NodePath

var start_time := 0.0
var reached := false

func _ready():
	start_time = Time.get_ticks_msec() / 1000.0
	print("⏱️ Timer started")

func _process(_delta):
	if reached:
		return

	var car = get_node_or_null(car_path)
	var flag = get_node_or_null(flag_path)

	if car and flag:
		if car.global_position.distance_to(flag.global_position) < 10.0:
			reached = true
			var total = (Time.get_ticks_msec() / 1000.0) - start_time
			print("🏁 Goal reached in %.2f seconds" % total)
