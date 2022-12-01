extends KinematicBody2D

var direction = Vector2.RIGHT
const initial_speed = 0
const final_speed = 250
var speed = initial_speed

const initial_spawn_time = 5
const final_spawn_time = 2

var max_hp = 50
var hp = max_hp setget set_hp

var awake = false

func _ready() -> void:
	randomize()
	direction = direction.rotated(randf() * 2 * PI)

func _physics_process(delta: float) -> void:
	speed = lerp(initial_speed, final_speed, 1 - float(hp) / max_hp)
	$AnimationPlayer.playback_speed = 1 - float(hp) / max_hp 
	if get_slide_count() > 0:
		Signals.emit_signal("shake", 1)
		$BounceSound.pitch_scale = rand_range(0.9, 1.1)
		$BounceSound.play()
		direction = direction.bounce(get_last_slide_collision().normal)
	move_and_slide(direction * speed)

func knock(dir, ignore=0):
	direction += dir * 0.3
	direction = direction.normalized()

func die():
	Signals.emit_signal("shake", 3)
	Signals.emit_signal("explode", global_position)
	queue_free()

func set_hp(new):
	if hp == new:
		return
	
	var diff = new - hp
	hp = new
	
	Signals.emit_signal("boss_hp_changed", float(hp) / max_hp)
#	if $SpawnTimer.is_stopped():
#		$SpawnTimer.wait_time = initial_spawn_time
#		$SpawnTimer.start()
	
	if hp <= 0:
		die()
	elif diff < 0:
		if not awake:
			awake = true
			$AnimationPlayer.play("spin")
		$ShadowSprite.flash()

func _on_Hitbox_body_entered(body: Node) -> void:
	if body == Globals.player:
		body.hp -= 1
#	elif "hp" in body:
#		body.hp = 0


func _on_SpawnTimer_timeout() -> void:
	Signals.emit_signal("spawn_unit", global_position)
	$SpawnTimer.wait_time = lerp(initial_spawn_time, final_spawn_time, 1 - float(hp) / max_hp)
	$SpawnTimer.start()
	
