extends Node2D

var player_up setget set_player_up
var enemy_up setget set_enemy_up

const char_time = 0.05

func _ready() -> void:
	$EnemyLabel.add_color_override("font_color", Globals.world_to_color[Globals.world])
	
	self.player_up = Upgrades.get_player_up()
	self.enemy_up = Upgrades.get_enemy_up()
			
	# TESTING
#	self.player_up = player_ups[-1]
#	self.enemy_up = enemy_ups[-1]

func type():
	type_label($PlayerLabel)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	type_label($EnemyLabel)
	$Tween.start()
	yield($Tween, "tween_all_completed")

func type_label(label):
	$Tween.interpolate_property(label, "percent_visible", 0, 1, char_time * len(label.text))
	
func apply():
	Signals.emit_signal("upgraded", Upgrades.get_player_up_text(player_up), Upgrades.get_enemy_up_text(enemy_up))
	Upgrades.apply_player_up(player_up)
	Upgrades.apply_enemy_up(enemy_up)

func set_player_up(new):
	player_up = new
	$PlayerLabel.text = Upgrades.get_player_up_text(player_up)

func set_enemy_up(new):
	enemy_up = new
	$EnemyLabel.text = Upgrades.get_enemy_up_text(enemy_up)


