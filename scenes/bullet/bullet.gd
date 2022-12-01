extends Area2D

var player = false
const speed = 500

var blast_dir = Vector2.ZERO

var dmg = 1
var piercing = false

func _process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func die():
	Signals.emit_signal("blast", $Sprite.global_position, blast_dir)
	queue_free()

func _on_Timer_timeout() -> void:
	die()

func _on_Bullet_body_entered(body: Node) -> void:
	if "data" in body and body.data.player == player:
		return
	
	if body.has_method("knock"):
		body.knock(Vector2.RIGHT.rotated(rotation), 1.5)
	
	if "hp" in body:
		if body.hp > 0:
			body.hp -= dmg
		Signals.emit_signal("bullet_hit")
		if piercing:
			return
			
	blast_dir = -Vector2.RIGHT.rotated(rotation)
	die()


func _on_Wall_body_entered(body):
	_on_Bullet_body_entered(body)
