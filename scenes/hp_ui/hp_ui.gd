tool extends Node2D

export (Texture) var filled
export (Texture) var empty

export (int) var hp = 4 setget set_hp
export (int) var max_hp = 8 setget set_max_hp

func _ready() -> void:
	self.max_hp = max_hp
	self.hp = hp
	update_ui()
	Signals.connect("hp_changed", self, "on_hp_changed")

func on_hp_changed(new_hp, new_max_hp):
	self.hp = new_hp
	self.max_hp = new_max_hp

func set_hp(new):
	if hp == new:
		return
	
	hp = new
	
	if is_inside_tree():
		update_ui()

func set_max_hp(new):
	if max_hp == new:
		return
	
	max_hp = new
	
	if is_inside_tree():
		update_ui()

func update_ui():
	for child in $Hearts.get_children():
		child.texture = empty
	for i in range(min(8, hp)):
		$Hearts.get_child(i).texture = filled
	
	for child in $Hearts.get_children():
		child.visible = false
	for i in range(min(8, max_hp)):
		$Hearts.get_child(i).visible = true
