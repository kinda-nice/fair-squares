extends Node2D

func _ready() -> void:
	Signals.connect("ammo_changed", self, "display")

func display(ammo):
	$Label.text = "x" + str(ammo)
