tool extends Node2D

export (Texture) var texture setget set_texture
export (float) var height = 0

func _ready() -> void:
	self.texture = texture

func _process(delta: float) -> void:
	$Sprite.position.y = -height
	$Buffer/Shadow.global_position = global_position + Vector2(1, 1)
	$Buffer/Shadow.global_rotation = global_rotation
	$Buffer/Shadow.scale = global_scale * max(0, 1 - height / 200)
	$Buffer/Shadow.visible = visible

func set_texture(new):
	texture = new
	
	if is_inside_tree():
		$Buffer/Shadow.texture = texture
		$Sprite.texture = texture

func flash():
	modulate = Color(100000, 100000, 100000, 1)
	$FlashTimer.start()

func _on_FlashTimer_timeout() -> void:
	modulate = Color(1, 1, 1, 1)
