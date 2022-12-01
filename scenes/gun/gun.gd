extends Node2D

var fire_rate = 3.0
var reload_time = 1
var max_ammo = 10
var spread = PI / 12
const bullet_scene = preload("res://scenes/bullet/bullet.tscn")

var dmg = 1
var piercing = false
var shots_per_fire = 1
var bullet_scale = 1

var ammo = max_ammo

var enabled = true

const key_to_dir = {
	"fire_left": Vector2.LEFT,
	"fire_right": Vector2.RIGHT,
	"fire_up": Vector2.UP,
	"fire_down": Vector2.DOWN
}

func _ready() -> void:
	Globals.gun = self
	Signals.connect("start_fight", self, "on_start_fight")
	Signals.connect("end_fight", self, "on_end_fight")
	Signals.connect("wipe_on_completed", self, "on_wipe_on")

func _process(delta: float) -> void:
	Signals.emit_signal("ammo_changed", ammo)
	$ReloadUI/Parent.global_position = global_position
	
	if not enabled:
		return
	
	if $ReloadAnim.is_playing():
		return
	
	if ammo <= 0 or (Input.is_action_just_pressed("reload") and ammo < max_ammo):
		if not $ReloadAnim.is_playing():
			start_reload()
			$FireTimer.stop()
	elif $FireTimer.is_stopped():
		var fire_dir = Vector2.ZERO
		if Input.is_action_pressed("fire"):
			fire_dir = get_global_mouse_position() - global_position
		else:
			for key in key_to_dir:
				if Input.is_action_pressed(key):
					fire_dir += key_to_dir[key]
			fire_dir = fire_dir.normalized()
		
		if fire_dir:
			fire(fire_dir)
			$FireTimer.wait_time = 1 / fire_rate
			$FireTimer.start()
		elif ammo < max_ammo and $PreReloadTimer.is_stopped() and not $ReloadAnim.is_playing():
			#$PreReloadTimer.start()
			pass

func start_reload():
	$ReloadAnim.playback_speed = 1.0 / reload_time
	$ReloadAnim.play("reload")

func on_start_fight():
	enabled = true
	
func on_end_fight():
	$FireTimer.stop()
	enabled = false

func on_wipe_on():
	self.ammo = max_ammo

func fire(dir):
	ammo -= 1
	$PreReloadTimer.stop()
	$ReloadAnim.play("RESET")
	
	for i in range(shots_per_fire):
		var bullet = bullet_scene.instance()
		bullet.global_position = global_position
		bullet.rotation = dir.angle() + rand_range(-spread / 2, spread / 2)
		bullet.player = get_parent().data.player
		bullet.piercing = piercing
		bullet.dmg = dmg
		bullet.scale *= bullet_scale
		Signals.emit_signal("spawn", bullet)
	$FireSound.pitch_scale = rand_range(0.9, 1.1)
	$FireSound.play()
	Signals.emit_signal("shake", 0.5)
	get_parent().knock(-dir)

func _on_FireTimer_timeout() -> void:
	if $ReloadAnim.is_playing():
		return
	
	if Input.is_action_pressed("fire"):
		fire(get_global_mouse_position() - global_position)
	else:
		$FireTimer.stop()

func _on_ReloadAnim_animation_finished(anim_name: String) -> void:
	if anim_name == "reload":
		ammo = max_ammo

func _on_PreReloadTimer_timeout() -> void:
	start_reload()
