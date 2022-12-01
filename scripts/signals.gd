extends Node

signal spawn(node)
signal spawn_unit(gpos, data)
signal blast(gpos, dir)
signal explode(gpos)
signal message(gpos, text, color)
signal shake(power)
signal zoom_in(gpos)

signal upgraded(player, enemy)

signal player_died(gpos)
signal game_won()

signal hurt_mode(on)

signal ammo_changed(ammo)
signal hp_changed(hp, max_hp)

signal wipe_on(gpos, delay)
signal wipe_on_completed()
signal world_ui_completed()
signal world_changed(world)
signal wipe_off(gpos, delay)
signal wipe_off_completed()

signal start_fight()
signal end_fight()

signal boss_hp_changed(prog)

signal bullet_hit()

signal play_music(song_name)
signal fade_music()
signal stop_music(click)
