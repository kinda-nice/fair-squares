extends Area2D

var upgrade = false
var custom = false
var custom_text = ""
var custom_color = Color(1, 1, 1, 1)
var falling_in = false

func _ready() -> void:
	$Floating/Upgrade.visible = upgrade
	$Floating/No.visible = not upgrade and not custom
	$Floating/Custom.text = custom_text
	$Floating/Custom.add_color_override("font_color", custom_color)
	$Floating/Custom.visible = custom
	set_deferred("monitoring", false)

func _on_Portal_body_entered(body: Node) -> void:
	if not falling_in and "data" in body and body.data.player:
		falling_in = true
		body.fall_in(global_position)
		if upgrade:
			$Floating/Upgrade.apply()
		else:
			Signals.emit_signal("upgraded", "", "")
		Signals.emit_signal("wipe_on", global_position, 0.5)
		yield(Signals, "wipe_on_completed")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		$AnimationPlayer.play("idle")
		set_deferred("monitoring", true)
