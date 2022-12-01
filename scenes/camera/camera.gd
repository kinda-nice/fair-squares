extends Camera2D

var shake = 0
var power = 2
var decay = 0.1

const zoom_in_time = 0.1
const zoom_out_time = 0.1
const zoomed_time = 0.25

func _ready() -> void:
	Signals.connect("shake", self, "_on_shake")
	Signals.connect("zoom_in", self, "zoom_in")

func _process(delta: float) -> void:
	offset = Vector2(shake * power, 0).rotated(randf() * 2 * PI)
	shake = max(0, shake - delta / decay)

func _on_shake(amount):
	shake = max(shake, amount)

func zoom_in(gpos):
	Engine.time_scale = 0.25
	$HurtLayer.visible = true
	$Tween.interpolate_property(self, "zoom", Vector2(1, 1), Vector2(0.5, 0.5), zoom_in_time, $Tween.TRANS_EXPO, $Tween.EASE_OUT)
	$Tween.interpolate_property(self, "global_position", global_position, gpos, zoom_in_time, $Tween.TRANS_EXPO, $Tween.EASE_OUT)
	
	$Tween.interpolate_property(self, "zoom", Vector2(0.5, 0.5), Vector2(1, 1), zoom_out_time, $Tween.TRANS_EXPO, $Tween.EASE_OUT, zoomed_time + zoom_in_time)
	$Tween.interpolate_property(self, "global_position", gpos, Vector2(320, 240) / 2, zoom_out_time, $Tween.TRANS_EXPO, $Tween.EASE_OUT, zoomed_time + zoom_in_time)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	Signals.emit_signal("hurt_mode", true)
	yield($Tween, "tween_completed")
	yield($Tween, "tween_completed")
	$HurtLayer.visible = false
	Signals.emit_signal("hurt_mode", false)
	yield($Tween, "tween_all_completed")
	Engine.time_scale = 1
