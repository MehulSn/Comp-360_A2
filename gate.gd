extends Node3D

@export var car_path: NodePath
@onready var gate_mesh = $MeshInstance3D
var is_open = false

func _process(delta):
	if car_path == null:
		return

	var car = get_node_or_null(car_path)
	if car == null:
		return

	var dist = global_position.distance_to(car.global_position)

	if dist < 25.0 and not is_open:
		is_open = true
		open_gate()
	elif dist >= 25.0 and is_open:
		is_open = false
		close_gate()

func open_gate():
	var tween = create_tween()
	tween.tween_property(gate_mesh, "rotation_degrees:z", -90.0, 1.5).set_trans(Tween.TRANS_SINE)
	print("🚗 Gate opened!")

func close_gate():
	var tween = create_tween()
	tween.tween_property(gate_mesh, "rotation_degrees:z", 0.0, 1.5).set_trans(Tween.TRANS_SINE)
	print("🚧 Gate closed!")
