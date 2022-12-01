extends CPUParticles2D

func _ready() -> void:
	$Sound.pitch_scale *= rand_range(0.9, 1.1)
	$Sound.play()
	$Timer.start()
	self.emitting = true

func _on_Timer_timeout() -> void:
	queue_free()
