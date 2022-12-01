extends Node2D

export (String) var text setget set_text
export (Color) var color setget set_color

func _ready() -> void:
	self.text = text
	self.color = color

func set_color(new):
	color = new
	
	if is_inside_tree():
		$Floats/Label.add_color_override("font_color", color)

func set_text(new):
	text = new
	
	if is_inside_tree():
		$Floats/Label.text = text
