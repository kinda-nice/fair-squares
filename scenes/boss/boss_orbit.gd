extends KinematicBody2D

signal fire

var direction = Vector2.RIGHT
const initial_speed = 100
const final_speed = 150
var speed = initial_speed

const initial_spawn_time = 0.2
const final_spawn_time = 0.1

var max_hp = 100
var hp = max_hp setget set_hp

const initial_max_bullets = 8
const final_max_bullets = 16
var max_bullets = initial_max_bullets
var bullets = 0
var bullet_angle = 0

const bullet_scene = preload("res://scenes/boss/boss_orbit_bullet.tscn")

var awake = false

func _ready() -> void:
	randomize()
	direction = direction.rotated(randf() * 2 * PI)

func _physics_process(delta: float) -> void:
	if not $WakeTimer.is_stopped():
		Signals.emit_signal("shake", 1)
	
	if not awake:
		return
	
	$AnimationPlayer.playback_speed = 1 - float(hp) / max_hp 
	speed = lerp(initial_speed, final_speed, 1 - float(hp) / max_hp)
	if get_slide_count() > 0:
		Signals.emit_signal("shake", 1)
		direction = direction.bounce(get_last_slide_collision().normal)
		$BounceSound.pitch_scale = rand_range(0.9, 1.1)
		$BounceSound.play()
	move_and_slide(direction * speed)

func spawn_bullet(angle):
	var bullet = bullet_scene.instance()
	bullet.parent = self
	bullet.position = global_position + 16 * Vector2.RIGHT.rotated(angle)
	bullet.angle = angle
	bullet.radius = 16
	bullet.max_radius = 36
	self.connect("fire", bullet, "fire")
	Signals.emit_signal("spawn", bullet)

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
	
	if hp <= 0:
		die()
	elif diff < 0:
		if not awake and $WakeTimer.is_stopped() and $PauseTimer.is_stopped():
			$Roar.play()
			$WakeTimer.start()
		$ShadowSprite.flash()

func _on_Hitbox_body_entered(body: Node) -> void:
	if body == Globals.player:
		body.hp -= 1

func _on_SpawnTimer_timeout() -> void:
	spawn_bullet(bullet_angle)
	bullet_angle += PI
	bullets += 1
	if bullets == max_bullets:
		$SpawnTimer.stop()
		$FireTimer.start()

func _on_FireTimer_timeout() -> void:
	$MagicSound.pitch_scale = rand_range(0.8, 1.2)
	$MagicSound.play()
	emit_signal("fire")
	bullets = 0
	$PauseTimer.start()
	yield($PauseTimer, "timeout")
	$SpawnTimer.wait_time = lerp(initial_spawn_time, final_spawn_time, 1 - float(hp) / max_hp)
	$SpawnTimer.start()
	max_bullets = int(lerp(initial_max_bullets, final_max_bullets, 1 - float(hp) / max_hp))
	bullet_angle = randf() * 2 * PI

func _on_WakeTimer_timeout():
	$PauseTimer.start()
	yield($PauseTimer, "timeout")
	awake = true
	$SpawnTimer.start()
	$AnimationPlayer.play("spin")
