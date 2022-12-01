extends Resource
class_name UnitData

export (bool) var player
export (Texture) var sprite

export (float) var scale = 1

export (int) var max_hp = 3
export (float) var vampirism = 0

export (int) var run_speed = 100

export (bool) var dashes
export (float) var dash_time = 1
export (int) var dash_min_speed = 100
export (int) var dash_max_speed = 300
export (float) var dash_chase_prob = 0.5
export (float) var dash_chase_spread = PI / 4
export (float) var dash_slide = 0

export (bool) var saws
export (int) var saw_speed = 100
export (float) var saw_magnetism = 0
export (float) var saw_confusion = 0

export (bool) var magic
export (int) var magic_amount = 3
export (float) var magic_spawn_time = 0.5
export (float) var magic_fire_time = 1
export (float) var magic_angle_speed = PI
export (float) var magic_pause_time = 0.5

export (bool) var kisses = false
