extends ColorRect

const wipe_on_time = 1

func _ready() -> void:
	Signals.connect("wipe_on", self, "wipe_on")
	Signals.connect("wipe_off", self, "wipe_off")

func wipe_on(gpos, delay):
	material.set_shader_param("pos", gpos / Vector2(320, 240))
	$Tween.interpolate_property(material, "shader_param/circle_size", 1.05, 0, wipe_on_time, Tween.TRANS_EXPO, Tween.EASE_OUT, delay)
	$Tween.start()
	yield($Tween, "tween_completed")
	Signals.emit_signal("wipe_on_completed")

func wipe_off(gpos, delay):
	material.set_shader_param("pos", gpos / Vector2(320, 240))
	$Tween.interpolate_property(material, "shader_param/circle_size", 0, 1.05, wipe_on_time, Tween.TRANS_EXPO, Tween.EASE_IN, delay)
	$Tween.start()
	yield($Tween, "tween_completed")
	Signals.emit_signal("wipe_off_completed")
