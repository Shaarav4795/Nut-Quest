@tool
extends SceneTree

const LEVELS := [
	"res://scenes/level/level_1.tscn",
	"res://scenes/level/level_2.tscn",
	"res://scenes/level/level_3.tscn",
]
const OUT_DIR := "res://assets/ui/level_thumbs"
const VIEW := Vector2(1024, 576)
const MARGIN := 48.0


func _initialize() -> void:
	_run()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	RenderingServer.set_default_clear_color(Color(0.36, 0.63, 0.75))

	for i in LEVELS.size():
		var level: Node2D = load(LEVELS[i]).instantiate()
		root.add_child(level)
		await process_frame
		await process_frame

		_frame(level)
		await process_frame
		await RenderingServer.frame_post_draw

		var image := root.get_texture().get_image()
		var out := "%s/level_%d.png" % [OUT_DIR, i + 1]
		image.save_png(out)
		print("wrote %s (%dx%d)" % [out, image.get_width(), image.get_height()])

		level.queue_free()
		await process_frame

	print("done - thumbs are in %s" % OUT_DIR)
	quit()


func _frame(level: Node2D) -> void:
	for cam in level.find_children("*", "Camera2D", true, false):
		cam.enabled = false

	var box := _bounds(level)
	if box.size == Vector2.ZERO:
		box = Rect2(Vector2.ZERO, VIEW)

	var camera := Camera2D.new()
	level.add_child(camera)
	camera.position = level.to_local(box.get_center())
	var zoom: float = minf(VIEW.x / box.size.x, VIEW.y / box.size.y)
	camera.zoom = Vector2(zoom, zoom)
	camera.make_current()


func _bounds(level: Node2D) -> Rect2:
	var box := Rect2()
	var started := false
	for node in level.find_children("*", "Node2D", true, false):
		var points: PackedVector2Array = []
		if node is Polygon2D:
			points = node.polygon
		elif node is CollisionPolygon2D:
			points = node.polygon
		for point in points:
			var global_point: Vector2 = node.to_global(point)
			if not started:
				box = Rect2(global_point, Vector2.ZERO)
				started = true
			else:
				box = box.expand(global_point)
	if started:
		box = box.grow(MARGIN)
	return box
