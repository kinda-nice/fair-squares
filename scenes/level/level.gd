tool extends Node2D

export (String) var fname
export (Globals.Level) var type
export (int) var world = 0

export (bool) var save_to_file = false setget set_save_to_file
export (bool) var load_from_file = false setget set_load_from_file

const unit_scene = preload("res://scenes/unit/unit.tscn")
const blast_scene = preload("res://scenes/explosion/blast.tscn")
const explosion_scene = preload("res://scenes/explosion/explosion.tscn")
const message_scene = preload("res://scenes/message/message.tscn")
const portal_scene = preload("res://scenes/portal/portal.tscn")
const gun_scene = preload("res://scenes/gun/gun.tscn")

const bg_colors = [Color("390947"), Color("09471a")]

const player_data = preload("res://resources/units/player.tres")

var fighting = false
var rounds_left = 1
const type_to_rounds_left = {
	Globals.Level.FIGHT: 3,
	Globals.Level.BOSS: 1
}

var size = Vector2(224, 176)

var level_ind = 3
const types = [
	Globals.Level.FIGHT, 
	Globals.Level.FIGHT, 
	Globals.Level.FIGHT, 
	Globals.Level.BOSS
	]

const unit_data = {
	"ai_red": preload("res://resources/units/ai_red.tres"),
	"ai_green": preload("res://resources/units/ai_green.tres"),
	"ai_pink": preload("res://resources/units/ai_pink.tres"),
	"ai_grey": preload("res://resources/units/ai_grey.tres")
}

onready var player = get_node_or_null("Player")
var reset = false

func _ready() -> void:
	Signals.connect("spawn", self, "spawn")
	Signals.connect("spawn_unit", self, "spawn_unit")
	Signals.connect("blast", self, "blast")
	Signals.connect("explode", self, "explode")
	Signals.connect("message", self, "message")
	Signals.connect("wipe_on_completed", self, "on_wipe_on_completed")
	Signals.connect("world_ui_completed", self, "load_level")
	Signals.connect("player_died", self, "on_player_died")
	Signals.connect("game_won", self, "on_player_died")
	
	Signals.emit_signal("world_changed", world)
	
	reset_level()

func _process(delta: float) -> void:
	if Engine.editor_hint or reset:
		return
	var all_dead = true
	for unit in $Units.get_children():
		all_dead = all_dead and (not unit or not is_instance_valid(unit))
	if all_dead and fighting:
		fighting = false
		if rounds_left <= 1:
			yield(get_tree().create_timer(1), "timeout")
			update_level_type()
			spawn_portal()
		else:
			load_round()
			fighting = true
			rounds_left -= 1

func on_player_died(gpos):
	reset = true
	Signals.emit_signal("wipe_on", gpos, 1)

func on_wipe_on_completed():
	for unit in $Units.get_children():
		unit.queue_free()
	for spawn in $Spawns.get_children():
		spawn.queue_free()

func spawn(node):
	var pos = node.position
	$Spawns.add_child(node)
	node.global_position = pos

func spawn_unit(gpos, udata):
	var unit = unit_scene.instance()
	unit.data = udata
	unit.position = gpos - $Units.global_position
	unit.start_delay = 0.5
	yield(get_tree(), "idle_frame")
	$Units.add_child(unit)

func blast(gpos, dir):
	var blast = blast_scene.instance()
	$Spawns.add_child(blast)
	blast.global_position = gpos
	blast.direction = dir

func explode(gpos):
	var explosion = explosion_scene.instance()
	$Spawns.add_child(explosion)
	explosion.global_position = gpos

func message(gpos, text, color):
	var msg = message_scene.instance()
	msg.position = gpos
	msg.text = text
	msg.color = color
	spawn(msg)

func update_level_type():
	level_ind += 1
	if level_ind == len(types):
		world += 1
		# $BG/Floor.color = bg_colors[world]
		Signals.emit_signal("world_changed", world)
		level_ind = 0
	type = types[level_ind]

func reset_level(to_start=true):
	reset = false
	fighting = false
	
	var new_data = {}
	for key in unit_data:
		new_data[key] = unit_data[key].duplicate()
	Globals.unit_data = new_data
	
	if to_start:
		type = Globals.Level.FIGHT
		world = -1
		fname = "tutorial"
		level_ind = 3
		rounds_left = 1
	
		$BG/TutorialIcons.visible = true
		for child in $Spawns.get_children():
			child.queue_free()
		for child in $Units.get_children():
			child.queue_free()
	
	if player and is_instance_valid(player):
		player.queue_free()
	player = unit_scene.instance()
	player.data = player_data.duplicate()
	player.position = size / 2
	add_child(player)
	var gun = gun_scene.instance()
	player.add_child(gun)
	player.drop_in(1.0)
	
	Signals.emit_signal("wipe_off", Vector2(320, 240) / 2, 0)
	yield(Signals, "wipe_off_completed")
	Signals.emit_signal("play_music", "tut")
	if to_start:
		deserialize()
	yield(get_tree(), "idle_frame")
	fighting = true

func load_level():
	if reset:
		reset_level()
		return
	
	$BG/TutorialIcons.visible = false
	for child in $Spawns.get_children():
		child.queue_free()
	player.position = size / 2
	player.drop_in(1.0)
	
	if type == Globals.Level.BOSS:
		load_round()
	Signals.emit_signal("play_music", "boss" if type == Globals.Level.BOSS else "fight")
	Signals.emit_signal("wipe_off", Vector2(320, 240) / 2, 0)
	yield(Signals, "wipe_off_completed")
	
	if type != Globals.Level.BOSS:
		load_round()
	rounds_left = type_to_rounds_left[type]
	
	yield(get_tree(), "idle_frame")
	fighting = true

func load_round():
	var fnames = Globals.dir_contents(get_save_dir())
	if len(fnames) == 0:
		return
	self.fname = fnames[randi() % len(fnames)].trim_suffix('.tres')
	deserialize(randi() % 2, randi() % 2)

func spawn_custom_portal(text):
	var portal = portal_scene.instance()
	portal.custom = true
	portal.custom_text = text
	var ind = world % len(Globals.world_to_color)
	portal.custom_color = Globals.world_to_color[ind]
	$Spawns.add_child(portal)
	portal.position = size / 2

func win_game():
	Signals.emit_signal("stop_music", true)
	yield(get_tree().create_timer(1), "timeout")
	spawn_unit(Vector2(320, 240) / 2, preload("res://resources/units/friend.tres"))

func spawn_portal():
	if world > 2:
		win_game()
		return
	if level_ind % len(types) == 0:
		if player and is_instance_valid(player):
			player.hp = player.data.max_hp
			spawn_custom_portal("fight!")
#			Signals.emit_signal("fade_music")
		return
		
	player.hp += 1
	
	if level_ind == len(types) - 1:
		spawn_custom_portal("?")
#		Signals.emit_signal("fade_music")
		return
	
	for i in range(2):
		var portal = portal_scene.instance()
		portal.upgrade = i == 0
		$Spawns.add_child(portal)
		portal.position = Vector2(size.x * i + 40 * (1 - 2 * i), size.y / 2)
		yield(get_tree().create_timer(3), "timeout")
	
func get_save_dir():
	return "res://resources/levels/" + Globals.level_name(type) + "/" + str(world)

func get_save_path():
	if not fname:
		assert(false)
	return get_save_dir() + "/" + fname + ".tres"

func set_save_to_file(new):
	if new:
		serialize()

func set_load_from_file(new):
	if new:
		deserialize()

func serialize():
	var data = {}
	data["units"] = []
	for unit in $Units.get_children():
		var unit_data = {}
		unit_data["fname"] = unit.get_filename()
		unit_data["position"] = unit.position
		if "data" in unit:
			unit_data["data_name"] = unit.data.resource_path.get_file().trim_suffix('.tres')
		data["units"].append(unit_data)
	
	var save = SaveData.new()
	save.data = data
	
	var directory = Directory.new()
	var dir_path = get_save_dir()
	if not directory.dir_exists(dir_path):
		directory.make_dir_recursive(dir_path)
	
	ResourceSaver.save(get_save_path(), save)

func deserialize(flip_h=false, flip_v=false):
	var save = ResourceLoader.load(get_save_path()).data
	
	for child in $Units.get_children():
		child.queue_free()
	
	yield(get_tree(), "idle_frame")
	
	var drop_delay = 1
	var units = []
	
	for info in save["units"]:
		var unit
		if "fname" in info:
			unit = load(info["fname"]).instance()
		else:
			unit = unit_scene.instance()
		
		for key in info:
			if key == "data_name":
				unit.data = Globals.unit_data[info[key]]
			elif key == "data" or key == "fname":
				pass
			else:
				unit.set(key, info[key])
		if flip_h:
			unit.position.x = size.x - unit.position.x
		if flip_v:
			unit.position.y = size.y - unit.position.y
		
		if "drop_delay" in unit:
			unit.drop_delay = drop_delay
			drop_delay += 0.2
		units.append(unit)
	
	for unit in units:
		if "start_delay" in unit:
			unit.start_delay = drop_delay + 0.2
		$Units.add_child(unit)
		unit.set_owner(get_tree().get_edited_scene_root())
