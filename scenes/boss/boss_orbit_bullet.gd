extends KinematicBody2D

var parent
var radius = 6
var max_radius = 20
var angle = 0
const angular_speed = PI / 2
var angular_dir = 1

const rotation_speed = PI

const fire_speed = 300

var orbiting = true
var firing = false
var fire_prob = 0.3

var hp = 1 setget set_hp

const squash = 1.3
const squash_time = 0.05
const stretch = 1.3
const drop_in_time = 0.5

var dummy = 1

const blast_scene = preload("res://scenes/explosion/orbit_blast.tscn")

func _ready() -> void:
	randomize()
	$SpawnSound.pitch_scale = rand_range(0.8, 1.2)
	$SpawnSound.play()
	if parent:
		go_to_parent()
	$Dust.emitting = firing
	$Hitbox.set_collision_mask_bit(1, firing)

func _physics_process(delta: float) -> void:
	if not $CutsceneTween.is_active():
		rotation += rotation_speed * delta
	
	if orbiting and is_instance_valid(parent):
		angle += angular_speed * delta
		global_position = parent.global_position + radius * Vector2.RIGHT.rotated(angle)
	
	if firing:
		global_position += fire_speed * Vector2.RIGHT.rotated(angle) * delta
	elif not is_instance_valid(parent) and orbiting:
		fire()

func go_to_parent():
	$Tween.interpolate_property(self, "radius", radius, max_radius, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()

func fire():
	orbiting = false
	$PauseTimer.start()
	yield($PauseTimer, "timeout")
	$Dust.emitting = true
	firing = true
	$Hitbox.set_collision_mask_bit(1, true)

func set_hp(new):
	hp = new
	
	if hp == 0:
		die()

func die():
	var blast = blast_scene.instance()
	blast.direction = -Vector2.RIGHT.rotated(angle)
	blast.position = global_position
	Signals.emit_signal("spawn", blast)
	queue_free()

func _on_Hitbox_body_entered(body: Node) -> void:
	if body == parent:
		return
	if body == Globals.player:
		body.hp -= 1
		die()
	if firing:
		die()
