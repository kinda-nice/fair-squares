extends Node2D

var player_ind = -1

const move_time = 1

var top_pos
var visible_pos
var bottom_pos

const dot_offset = Vector2(3, 2)
onready var targets = [
	$Progress/HBoxContainer/BigDot.rect_position + dot_offset,
	$Progress/HBoxContainer/BigDot2.rect_position + dot_offset,
	$Progress/HBoxContainer/BigDot3.rect_position + dot_offset,
	$Progress/HBoxContainer/BigDot4.rect_position + dot_offset,
	]
	
const message_scene = preload("res://scenes/message/message.tscn")

var player_up_text = ""
var enemy_up_text = ""

var just_died = false

func _ready() -> void:
	visible = false
	Signals.connect("wipe_on_completed", self, "next")
	Signals.connect("upgraded", self, "on_upgraded")
	Signals.connect("player_died", self, "on_player_died")
	Signals.connect("game_won", self, "on_game_won")

func on_player_died(gpos):
	$DeathText.text = "all is square in love and war..."
	$Again.text = "again?"
	just_died = true
	player_ind = 3

func on_game_won(gpos):
	$DeathText.text = "all is square in war and love..."
	$Again.text = "congrats!"
	just_died = true

func next():
	visible = false
	if just_died:
		show_death()
		return
	
	$EnemyIcon/Sprite.modulate = Globals.world_to_color[Globals.world]
	player_ind += 1
	if player_ind >= 4:
		player_ind = 0
		$Progress/Player.position = targets[0]
	$Progress/World.text = str(Globals.world + 1)
	
	$EnemyIcon/BG.visible = player_ind != 3
	$EnemyIcon/Sprite.visible = player_ind != 3
	$EnemyIcon/Question.visible = player_ind == 3
	$AnimationPlayer.play("show")
	yield(get_tree(), "idle_frame")
	visible = true

func play_music():
	pass

func show_death():
	$AnimationPlayer.play("die")
	yield(get_tree(), "idle_frame")
	visible = true
	just_died = false

func on_upgraded(ptext, etext):
	player_up_text = ptext
	enemy_up_text = etext

func move_player():
	if player_ind != 0:
		$Whoosh.play()
	$Tween.interpolate_property($Progress/Player, "position", $Progress/Player.position, targets[player_ind], move_time, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()

func show_player_text():
	if player_up_text == "":
		$AnimationPlayer.seek(4.4)
		return
	$Bloop.play()
	var message = message_scene.instance()
	message.position = $PlayerIcon.position - Vector2(0, 10)
	message.text = player_up_text
	message.color = Globals.blue
	add_child(message)

func show_enemy_text():
	if enemy_up_text == "":
		$AnimationPlayer.seek(5.4)
		return
	$Bloop.play()
	var message = message_scene.instance()
	message.position = $EnemyIcon.position - Vector2(0, 10)
	message.text = enemy_up_text
	message.color = Globals.world_to_color[Globals.world]
	add_child(message)

func finish():
	Signals.emit_signal("world_ui_completed")

func _on_AnimationPlayer_animation_finished(anim_name):
	visible = false
