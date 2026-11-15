extends CanvasLayer

var elapsed_time: float = 0.0

@onready var timer_label = $timer_label


func _process(delta):
	elapsed_time += delta
	update_display()


func update_display():
	var total_seconds = int(elapsed_time)

	var minutes = total_seconds / 60
	var seconds = total_seconds % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]
