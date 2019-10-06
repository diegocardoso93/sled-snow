extends KinematicBody2D

var speed = 300 # Pixels/second
var direction = 0
var v1 = 0
var dead = false
var points = 0
var finish = false

var sled1 = preload("res://graphics/Isometric/sled_NW.png")
var sled2 = preload("res://graphics/Isometric/sled_SE.png")

onready var sound_pick = get_node("SoundPick")
onready var sound_death = get_node("SoundDeath")

func _physics_process(delta):
	var motion = Vector2()
	speed = 300
	if finish:
		speed -= 20

	if Input.is_action_pressed("ui_up"):
		speed = 0
	if Input.is_action_pressed("ui_bottom"):
		direction = 1
		v1 = 0
	if Input.is_action_pressed("ui_left"):
		direction = 2
		if v1 >= -1:
			v1 -= 0.1
	if Input.is_action_pressed("ui_right"):
		direction = 3
		if v1 <= 1:
			v1 += 0.1

	if direction == 1:
		motion += Vector2(v1, 1)
	if direction == 2:
		motion += Vector2(v1, 1)
	if direction == 3:
		motion += Vector2(v1, 1)

	motion = motion.normalized() * speed * delta
	if motion.angle() > 1.6:
		get_node("Sprite").set_texture(sled2)
	else:
		get_node("Sprite").set_texture(sled1)

	var collision_info = move_and_collide(motion)
	if collision_info:
		var collision_point = collision_info.position
		if (collision_info.collider.get("name") == "walls"):
			dead = true
			sound_death.play()
			OS.delay_msec(500)
			get_tree().change_scene("res://scenes/gameover.tscn")

		if (collision_info.collider.get("name") == "floor"):
			finish = true
			save_score()
			get_tree().change_scene("res://scenes/gameend.tscn")

func collected(origin):
	sound_pick.play()
	points += 1
	get_node("/root/game/ui/Points").set_text(String(points))
	origin.queue_free()

func save_score():
	var score = 0
	if points == 16:
		score = 3
	elif points > 10:
		score = 2
	elif points > 5:
		score = 1
	else:
		score = 0

	var save_game = File.new()
	if save_game.file_exists("user://savegame.save"):
		save_game.open("user://savegame.save", File.READ)
		var gameSave = save_game.get_var()
		save_game.close()
		if score >= gameSave.stages[gameSave.current-1].status:
			save_game.open("user://savegame.save", File.WRITE)
			gameSave.stages[gameSave.current-1].status = score + 1
			save_game.store_var(gameSave)
			save_game.close()