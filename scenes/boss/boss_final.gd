extends KinematicBody2D

var max_hp = 200
var hp = max_hp setget set_hp

const sweep_bullets = 6
const level_size = Vector2(224, 176)
const level_offset = (Vector2(320, 240) - level_size) / 2
const spawn_buffer = Vector2(20, 20)
var unit_spawns = [spawn_buffer, Vector2(spawn_buffer.x, level_size.y - spawn_buffer.y), Vector2(level_size.x - spawn_buffer.x, spawn_buffer.y), level_size - spawn_buffer]
const sweep_height = level_size.y

const bullet_scene = preload("res://scenes/boss/boss_orbit_bullet.tscn")

var children = []

var sweeps_done = 0

var awake = false

func _process(delta):
	if not $WakeTimer.is_stopped():
		Signals.emit_signal("shake", 1)

func bullet_sweep():
	var ltor = Globals.player and is_instance_valid(Globals.player) and (Globals.player.global_position - global_position).x > 0
	var blank = randi() % sweep_bullets
	var bullets = []
	for i in range(sweep_bullets):
		if i == blank:
			continue
		var bullet = bullet_scene.instance()
		var height = lerp(0, sweep_height, float(i + 0.5) / (sweep_bullets))
		bullet.position = level_offset + Vector2(0 if ltor else level_size.x, height)
		bullet.angle = 0 if ltor else PI
		bullet.orbiting = false
		Signals.emit_signal("spawn", bullet)
		bullets.append(bullet)
		$PauseTimer.start()
		yield($PauseTimer, "timeout")
	
	for bullet in bullets:
		bullet.fire()

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
		if not awake:
			$Roar.play()
			$WakeTimer.start()
			awake = true
		$ShadowSprite.flash()

func _on_Hitbox_body_entered(body: Node) -> void:
	if body == Globals.player:
		body.hp -= 1

func _on_SweepTimer_timeout():
	bullet_sweep()
	$SweepTimer.start()

func _on_SpawnTimer_timeout():
	if not Globals.player or not is_instance_valid(Globals.player):
		return
	var coord_i = 0
	for i in range((randi() % 3) + 1):
		var data = Globals.unit_data.values()[randi() % 3]
		Signals.emit_signal("spawn_unit", level_offset + unit_spawns[coord_i], data)
		coord_i += 1
		$PauseTimer.start()
		yield($PauseTimer, "timeout")

func _on_WakeTimer_timeout():
	$SweepTimer.start()
	_on_SpawnTimer_timeout()
	$SpawnTimer.start()
