extends Node

func _ready():
	randomize()

func get_player_up():
	var p_up = 0
	for i in range(100):
		if not Globals.player or not is_instance_valid(Globals.player):
			return 0
		p_up = randi() % len(player_ups)
		if not "cond" in player_ups[p_up] or call(player_ups[p_up]["cond"]):
			break
	
	# debug
	# p_up = len(player_ups) - 1
	return p_up

func get_player_up_text(up):
	return player_ups[up]["text"]

func apply_player_up(up):
	call(player_ups[up]["func"])
	player_ups.remove(up)

func get_enemy_up():
	var ups = [red_enemy_ups, green_enemy_ups, pink_enemy_ups][Globals.world]
	
	var up = 0
	for i in range(100):
		if not Globals.player or not is_instance_valid(Globals.player):
			return 0
		up = randi() % len(ups)
		if not "cond" in ups[up] or call(ups[up]["cond"]):
			break
	
	return up

func get_enemy_up_text(up):
	var ups = [red_enemy_ups, green_enemy_ups, pink_enemy_ups][Globals.world]
	return ups[up]["text"]

func apply_enemy_up(up):
	var ups = [red_enemy_ups, green_enemy_ups, pink_enemy_ups][Globals.world]
	call(ups[up]["func"])
	ups.remove(up)

# UPGRADE FNS ------------------------------------------------------------------
var player_ups = [
	{
		"cond": "cond_player_tank",
		"func": "player_tank",
		"text": "tanky"
	},
	{
		"func": "player_piercing",
		"text": "piercing shots"
	},
	{
		"func": "player_sniper",
		"text": "sniper"
	},
	{
		"func": "player_shotgun",
		"text": "shotgun"
	},
	{
		"func": "player_vampirism",
		"text": "vampirism"
	},
	{
		"func": "player_twin_shot",
		"text": "twin shot"
	},
	{
		"func": "player_big_shots",
		"text": "big shots"
	},
	{
		"cond": "cond_player_well_rounded",
		"func": "player_well_rounded",
		"text": "well rounded"
	},
	{
		"func": "player_speedy",
		"text": "speedy"
	},
	{
		"func": "player_triple_shot",
		"text": "triple shot"
	},
	{
		"func": "player_tiny",
		"text": "tiny"
	},
	{
		"func": "player_smg",
		"text": "smg"
	},
	{
		"cond": "cond_player_healthy",
		"func": "player_healthy",
		"text": "healthy"
	}
	
]

func cond_player_tank():
	return Globals.player.hp <= 5

func player_tank():
	Globals.player.data.max_hp = min(Globals.player.data.max_hp + 3, 8)
	Globals.player.hp = min(Globals.player.hp + 3, 8)
	Globals.player.data.run_speed *= 0.8

func player_piercing():
	Globals.gun.piercing = true

func player_sniper():
	Globals.gun.dmg *= 3
	Globals.gun.fire_rate = 1 / (1.0 / Globals.gun.fire_rate + 0.5)
	Globals.gun.reload_time += 1
	Globals.gun.spread *= 0.5

func player_shotgun():
	Globals.gun.fire_rate = 1 / (1.0 / Globals.gun.fire_rate + 0.5)
	Globals.gun.max_ammo = max(int(0.2 * Globals.gun.max_ammo), 1)
	Globals.gun.ammo = Globals.gun.max_ammo
	Globals.gun.shots_per_fire *= 8
	Globals.gun.spread *= 3
	Globals.gun.reload_time += 1

func player_vampirism():
	Globals.player.data.vampirism += 0.03

func player_twin_shot():
	Globals.gun.shots_per_fire *= 2
	Globals.gun.fire_rate = 1 / (1.0 / Globals.gun.fire_rate + 0.2)
	Globals.gun.spread *= 2

func player_big_shots():
	Globals.gun.bullet_scale *= 1.5

func cond_player_well_rounded():
	return Globals.player.hp <= 7

func player_well_rounded():
	Globals.player.data.max_hp += 1
	Globals.player.hp = Globals.player.data.max_hp
	Globals.player.data.run_speed *= 1.1
	Globals.gun.max_ammo += 5
	Globals.gun.ammo = Globals.gun.max_ammo
	Globals.gun.fire_rate *= 1.2

func player_speedy():
	Globals.player.data.run_speed *= 1.3
	Globals.gun.reload_time *= 0.8

func player_triple_shot():
	Globals.gun.shots_per_fire *= 3
	Globals.gun.fire_rate = 1 / (1.0 / Globals.gun.fire_rate + 0.4)
	Globals.gun.spread *= 3

func player_tiny():
	Globals.player.data.scale *= 0.7
	Globals.player.data.run_speed *= 1.2

func player_smg():
	Globals.gun.fire_rate *= 2.5
	Globals.gun.reload_time *= 1.2
	Globals.gun.bullet_scale *= 0.6
	Globals.gun.spread *= 2

func cond_player_healthy():
	return Globals.player.data.max_hp <= 6

func player_healthy():
	Globals.player.data.max_hp += 2
	Globals.player.hp = Globals.player.data.max_hp
	Globals.player.data.run_speed *= 1.1

var red_enemy_ups = [
	{
		"func": "red_enemy_beefy",
		"text": "beefy"
	},
	{
		"func": "red_enemy_energetic",
		"text": "energetic"
	},
	{
		"func": "red_enemy_aggressive",
		"text": "aggressive"
	},
	{
		"func": "red_enemy_on_skates",
		"text": "on skates"
	},
	{
		"func": "red_enemy_huge",
		"text": "huge"
	}
]

func red_enemy_beefy():
	var data = Globals.unit_data["ai_red"]
	data.max_hp += 2
	data.scale += 0.2

func red_enemy_energetic():
	var data = Globals.unit_data["ai_red"]
	data.dash_time *= 0.4
	data.dash_min_speed *= 0.7
	data.dash_max_speed *= 0.7

func red_enemy_aggressive():
	var data = Globals.unit_data["ai_red"]
	data.dash_chase_prob = 1.0
	data.dash_chase_spread *= 0.5

func red_enemy_on_skates():
	var data = Globals.unit_data["ai_red"]
	data.dash_slide += 0.3

func red_enemy_huge():
	var data = Globals.unit_data["ai_red"]
	data.scale += 0.5
	data.dash_min_speed *= 1.2
	data.dash_max_speed *= 1.2

var green_enemy_ups = [
	{
		"func": "green_enemy_huge",
		"text": "huge"
	},
	{
		"func": "green_enemy_magnetic",
		"text": "magnetic"
	},
	{
		"func": "green_enemy_agile",
		"text": "agile"
	},
	{
		"func": "green_enemy_confused",
		"text": "confused"
	}
]

func green_enemy_huge():
	var data = Globals.unit_data["ai_green"]
	data.scale *= 1.7
	data.saw_speed *= 1.1

func green_enemy_magnetic():
	var data = Globals.unit_data["ai_green"]
	data.saw_magnetism += 2

func green_enemy_agile():
	var data = Globals.unit_data["ai_green"]
	data.scale *= 0.8
	data.saw_speed *= 1.5

func green_enemy_confused():
	var data = Globals.unit_data["ai_green"]
	data.saw_confusion += 1

var pink_enemy_ups = [
	{
		"func": "pink_enemy_hardworking",
		"text": "hardworking"
	},
	{
		"func": "pink_enemy_frantic",
		"text": "frantic"
	},
	{
		"func": "pink_enemy_rapid_fire",
		"text": "rapid fire"
	},
	{
		"func": "pink_enemy_fearless",
		"text": "fearless"
	}
]

func pink_enemy_hardworking():
	var data = Globals.unit_data["ai_pink"]
	data.magic_amount += 2
	data.magic_spawn_time *= 0.6

func pink_enemy_frantic():
	var data = Globals.unit_data["ai_pink"]
	data.magic_angle_speed *= 1.5
	data.magic_pause_time *= 0.25
	data.magic_fire_time *= 0.5
	data.magic_spawn_time *= 0.5

func pink_enemy_rapid_fire():
	var data = Globals.unit_data["ai_pink"]
	data.magic_amount -= 2
	data.magic_spawn_time *= 0.25
	data.magic_fire_time *= 0.25
	data.magic_pause_time = 0

func pink_enemy_fearless():
	var data = Globals.unit_data["ai_pink"]
	data.dash_time *= 0.8
	data.dash_chase_prob = 1
	data.dash_min_speed *= 1.2
	data.dash_max_speed *= 1.2
