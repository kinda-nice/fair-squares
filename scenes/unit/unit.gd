tool extends KinematicBody2D

export (Resource) var data setget set_data

signal drop_in_over()

var hp = 3 setget set_hp

const squash = 1.3
const squash_time = 0.05
const stretch = 1.3

const fall_in_time = 1
const drop_in_time = 0.5

var direction = Vector2.ZERO
var prev_dir = Vector2.ZERO
var speed = 0
var dashing = false
var in_cutscene = false

const knockback_speed = 100
var knockback_vel = Vector2.ZERO

var drop_delay = 0
var start_delay = 0

func _ready() -> void:
	randomize()
	self.data = data
	self.hp = data.max_hp
	
	if Engine.editor_hint:
		return
	
	if data.player:
		player_ready()
	else:
		ai_ready()

func _physics_process(delta: float) -> void:
	if Engine.editor_hint or in_cutscene:
		return
	
	if not data.player and get_slide_count() > 0:
		var collision = get_last_slide_collision()
		if Globals.player and collision.collider == Globals.player:
			if data.kisses:
				kiss()
				return
			Globals.player.hp -= 1
			die()
		elif dashing or data.saws:
			$BounceSound.pitch_scale = rand_range(0.7, 1.3)
			$BounceSound.play()
			direction = direction.bounce(collision.normal).rotated(data.saw_confusion * rand_range(-PI / 2, PI / 2))
			confusion_factor = 1 + rand_range(-0.25, 0.5) * data.saw_confusion
			rotation = direction.angle()
	
	if data.player:
		player_process(delta)
	else:
		ai_process(delta)
	
	var velocity = direction * speed
	velocity += get_knockback()
	move_and_slide(velocity)
	prev_dir = direction

func dash(dir, top_speed, dash_time):
	rotation = dir.angle()
	$DashTween.interpolate_property(self, "scale", data.scale * Vector2(1, 1), data.scale * Vector2(1 / squash, squash), squash_time, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$DashTween.start()
	yield($DashTween, "tween_all_completed")
	$DashSound.pitch_scale = rand_range(0.8, 1.2)
	$DashSound.play()
	dashing = true
	direction = dir
	$DashTween.interpolate_property(self, "speed", top_speed, top_speed * data.dash_slide, dash_time, Tween.TRANS_EXPO, Tween.EASE_IN)
	$DashTween.interpolate_property(self, "scale", data.scale * Vector2(1, 1), data.scale * Vector2(stretch, 1 / stretch), dash_time / 2, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$DashTween.interpolate_property(self, "scale", data.scale * Vector2(stretch, 1 / stretch), data.scale * Vector2(1, 1), dash_time / 2, Tween.TRANS_EXPO, Tween.EASE_OUT, dash_time / 2)
	$DashTween.start()
	yield($DashTween, "tween_all_completed")
	dashing = false

func set_data(new):
	data = new
	
	if data and is_inside_tree():
		scale = Vector2(data.scale, data.scale)
		$ShadowSprite.texture = data.sprite
		$Dust.texture = data.sprite
		$DashTimer.wait_time = data.dash_time
		
		$MagicFireTimer.wait_time = data.magic_fire_time
		$MagicSpawnTimer.wait_time = data.magic_spawn_time
		
		hp = data.max_hp
		
		if data.player:
			Globals.player = self

func die():
	if data.player:
		Signals.emit_signal("player_died", global_position)
	Signals.emit_signal("explode", global_position)
	queue_free()

func set_hp(new):
	if new > data.max_hp:
		new = data.max_hp
	
	var diff = new - hp
	
	if data.player:
		player_hp_changed(new)
		return
	hp = new

	if hp <= 0:
		die()
	elif diff < 0:
		$ShadowSprite.flash()

func fall_in(gpos):
	in_cutscene = true
	Signals.emit_signal("end_fight")
	$Dust.emitting = false
	$CutsceneTween.interpolate_property(self, "global_position", global_position, gpos, fall_in_time, Tween.TRANS_QUAD, Tween.EASE_IN)
	$CutsceneTween.interpolate_property(self, "rotation_degrees", rotation_degrees, rotation_degrees + 360, fall_in_time, Tween.TRANS_QUAD, Tween.EASE_IN)
	$CutsceneTween.interpolate_property(self, "scale", scale, Vector2.ZERO, fall_in_time, Tween.TRANS_QUAD, Tween.EASE_IN)
	$CutsceneTween.start()
	yield(Signals, "wipe_on_completed")
	scale = data.scale * Vector2(1, 1)
	in_cutscene = false
	# $Dust.emitting = true

func drop_in(delay=0, sdelay=0):
	in_cutscene = true
	call_deferred("set_collision_layer_bit", 0, false)
	call_deferred("set_collision_mask_bit", 0, false)
	rotation = 0
	$Dust.emitting = false
	$ShadowSprite.height = 300
	$ShadowSprite.visible = true
	visible = true
	$CutsceneTween.interpolate_property($ShadowSprite, "height", 300, 0, drop_in_time, Tween.TRANS_QUAD, Tween.EASE_IN, delay)
	$CutsceneTween.interpolate_property(self, "scale", Vector2(data.scale / stretch / 2, data.scale * stretch * 2), data.scale * Vector2(1, 1), drop_in_time, Tween.TRANS_QUAD, Tween.EASE_IN, delay)
	$CutsceneTween.interpolate_property(self, "scale", Vector2(data.scale * squash, data.scale / squash), data.scale * Vector2(1, 1), squash_time, Tween.TRANS_EXPO, Tween.EASE_IN, delay + drop_in_time)
	$CutsceneTween.start()
	yield($CutsceneTween, "tween_completed")
	$LandSound.pitch_scale = rand_range(0.9, 1.1)
	$LandSound.play()
	yield($CutsceneTween, "tween_all_completed")
	call_deferred("set_collision_layer_bit", 0, true)
	call_deferred("set_collision_mask_bit", 0, true)
	Signals.emit_signal("shake", 1)
	if delay < sdelay:
		$DelayTimer.wait_time = sdelay - delay
		$DelayTimer.start()
		yield($DelayTimer, "timeout")
	$Dust.emitting = true
	in_cutscene = false
	emit_signal("drop_in_over")
	if data.player:
		Signals.emit_signal("start_fight")

func get_knockback():
	if not $KnockbackTimer.is_stopped():
		return knockback_vel
	return Vector2.ZERO

func knock(dir, factor=1):
	knockback_vel = dir.normalized() * knockback_speed * factor
	$KnockbackTimer.start()

# AI ---------------------------------------------------------------------------
signal fire()

var last_dash_dir = Vector2.LEFT

var confusion_factor = 1.0

var orbit_target
var orbit_angle = 0
const orbit_radius = 20

var magic_orbiting = 0
const magic_scene = preload("res://scenes/boss/boss_orbit_bullet.tscn")
var magic_angle = 0

func ai_ready():
	if data.kisses:
		Signals.emit_signal("end_fight")
	drop_in(drop_delay, start_delay)
	yield(self, "drop_in_over")
	if data.dashes:
		_on_DashTimer_timeout()
		$DashTimer.start()
	if data.saws:
		direction = Vector2.RIGHT.rotated(randf() * 2 * PI)
	if data.magic:
		$MagicSpawnTimer.start()
		magic_angle = randf() * 2 * PI

func ai_process(delta):
	if data.saws:
		speed = data.saw_speed * confusion_factor
		if Globals.player and is_instance_valid(Globals.player):
			direction += global_position.direction_to(Globals.player.global_position) * data.saw_magnetism * delta
			direction = direction.normalized()
	if data.magic:
		magic_angle += data.magic_angle_speed * delta

func _on_DashTimer_timeout() -> void:
	if Engine.editor_hint:
		return
	if not direction:
		direction = Vector2.RIGHT.rotated(randf() * 2 * PI)
	
	var new_dir
	if randf() < data.dash_chase_prob and Globals.player and is_instance_valid(Globals.player):
		new_dir = global_position.direction_to(Globals.player.global_position).rotated(rand_range(-data.dash_chase_spread / 2, data.dash_chase_spread / 2))
	else:
		new_dir = (-last_dash_dir).rotated(rand_range(-PI / 2, PI / 2))
	
	dash(new_dir, rand_range(data.dash_min_speed, data.dash_max_speed), 0.3)
	last_dash_dir = new_dir
	$DashTimer.start()

func spawn_magic(angle):
	var magic = magic_scene.instance()
	magic.parent = self
	magic.position = global_position + magic.radius * Vector2.RIGHT.rotated(angle)
	magic.angle = angle
	self.connect("fire", magic, "fire")
	Signals.emit_signal("spawn", magic)

func _on_MagicSpawnTimer_timeout() -> void:
	spawn_magic(magic_angle)
	magic_orbiting += 1
	if magic_orbiting == data.magic_amount:
		$MagicFireTimer.start()
	else:
		$MagicSpawnTimer.start()

func _on_MagicFireTimer_timeout() -> void:
	$MagicSound.pitch_scale = rand_range(0.8, 1.2)
	$MagicSound.play()
	emit_signal("fire")
	magic_angle = randf() * 2 * PI
	magic_orbiting = 0
	$DelayTimer.wait_time = data.magic_pause_time
	$DelayTimer.start()
	yield($DelayTimer, "timeout")
	$MagicSpawnTimer.start()

func kiss():
	in_cutscene = true
	Globals.player.in_cutscene = true
	Signals.emit_signal("play_music", "win")
	yield(get_tree().create_timer(7), "timeout")
	$KissSound.play()
	yield($KissSound, "finished")
	Signals.emit_signal("message", (global_position + Globals.player.global_position) / 2, "<3", Globals.red)
	yield(get_tree().create_timer(0.7), "timeout")
	Signals.emit_signal("game_won", (global_position + Globals.player.global_position) / 2)
	

# PLAYER -----------------------------------------------------------------------
const key_to_dir = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}

const hurt_messages = ["ow!", "ouch!", "oof!"]

func player_ready():
	Signals.connect("hurt_mode", self, "set_hurt_mode")
	Signals.connect("bullet_hit", self, "on_bullet_hit")

func set_hurt_mode(on):
	$HurtSprite.visible = on

func player_process(delta):
	speed = data.run_speed
	direction = Vector2.ZERO
	for key in key_to_dir:
		if Input.is_action_pressed(key):
			direction += key_to_dir[key]
	direction = direction.normalized()
	tilt()
	
	Signals.emit_signal("hp_changed", hp, data.max_hp)

func player_hp_changed(new):
	if new > data.max_hp:
		new = data.max_hp
	
	var diff = new - hp
	
	if not $InvincibleTimer.is_stopped() and diff < 0:
		return
	
	hp = new
	
	if hp <= 0:
		Signals.emit_signal("stop_music", false)
		die()
	elif diff < 0:
		$PlayerHurtSound.play()
		Signals.emit_signal("shake", 2)
		Signals.emit_signal("message", global_position, hurt_messages[randi() % len(hurt_messages)], Globals.blue)
		set_collision_layer_bit(0, false)
		set_collision_mask_bit(0, false)
		$InvincibleTimer.start()
		$BlinkTimer.start()
		$Dust.emitting = false
	elif diff > 0:
		Signals.emit_signal("message", global_position, "+" + str(diff), Globals.blue)
	Signals.emit_signal("hp_changed", hp, data.max_hp)

func tilt():
	if direction != prev_dir:
		var new_rotation = PI / 12 * direction.x
		$TiltTween.interpolate_property(self, "rotation", rotation, new_rotation, 0.2, Tween.TRANS_EXPO, Tween.EASE_OUT)
		$TiltTween.start()

func _on_BlinkTimer_timeout() -> void:
	$ShadowSprite.visible = not $ShadowSprite.visible

func _on_InvincibleTimer_timeout() -> void:
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0, true)
	$BlinkTimer.stop()
	$ShadowSprite.visible = true
	$Dust.emitting = true

func on_bullet_hit():
	if randf() < data.vampirism:
		self.hp += 1
