tool extends Node

var unit_data = {
	"ai_red": preload("res://resources/units/ai_red.tres"),
	"ai_green": preload("res://resources/units/ai_green.tres"),
	"ai_pink": preload("res://resources/units/ai_pink.tres"),
	"ai_grey": preload("res://resources/units/ai_grey.tres")
}

var player
var gun
var world = 0

func _ready() -> void:
	Signals.connect("world_changed", self, "world_changed")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		return
		var image = get_viewport().get_texture().get_data()
		image.flip_y()
		var time = OS.get_time()
		var time_return = String(time.hour) + String(time.minute) + String(time.second)
		image.save_png("res://screenshots/" + time_return + ".png")

func world_changed(new):
	world = new

enum Level {FIGHT, BOSS}

func level_name(level):
	return Level.keys()[level]

const yellow = Color("fcef8d")
const red = Color("ea6262")
const blue = Color("6d80fa")
const green = Color("6bc96c")
const pink = Color("ee8fcb")

const world_to_color = [red, green, pink]

func dir_contents(path):
	var out = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				out.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return out

func get_enemy_data():
	return unit_data.values()
