extends KinematicBody2D

# Movement Variables.
export var speed := 200;
export var acceleration := 0.3;
var direction := Vector2.ZERO;
var velocity := Vector2.ZERO;

# Sprite Scene Instances.
onready var bullet_scene := preload("res://Props/Bullet/Bullet.tscn");
onready var weapon := $Hand/Gun/Sprite;
onready var muzzle := $Hand/Gun/Muzzle;
onready var sfx := $sfx;
onready var gun_cooldown := $Hand/Gun/Cooddown;
# SFX for player actions.
onready var sfx_shoot := preload("res://Assets/Music/SFX/shoot-6-81136.mp3")
onready var sfx_run := preload("res://Assets/Music/SFX/st2-footstep-sfx-323055.mp3")
# Variables to manage shooting mechanism.
var weapon_offset_x := 3;
var bullet_offset := Vector2(13,13);
var recoil_strength := 3;
var bullets_shot = 0;
# Checker for player direction and movement states.
var facingRight = true;
var isMoving = true;
# Variables for Screen-Shake Mechanism.
var shakeTimer := 0.0;
var shakeTime := 0.1;

# Function to play SFX.
func play_sfx(stream):
	var random_pitch = rand_range(0.5,2);
	match(stream):
		"run":
			if sfx.stream != sfx_run or not sfx.playing:
					sfx.stream = sfx_run
					sfx.pitch_scale = random_pitch;
					sfx.play();
		"shoot":
			sfx.stream = sfx_shoot;
			sfx.pitch_scale = random_pitch;
			sfx.play();
			return;

# Callback to handle scene quit() and shoot().(Temporary)
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if event is InputEventMouseButton:
		bullets_shot += 1;
		if bullets_shot <= 1:
			shoot();
			play_sfx("shoot")
			gun_cooldown.start();


# Function to set label text of player.
func setStateLabel(txt : String):
	var player_label := $Control/StatesLabel;
	player_label.bbcode_text = txt;

# Function to handle movement logic.
func handleMovement(delta):
	var new_direction = Vector2.ZERO;

	if Input.is_action_pressed("up"):
		new_direction.y -= 1
	if Input.is_action_pressed("down"):
		new_direction.y += 1
	if Input.is_action_pressed("right"):
		new_direction.x += 1
	if Input.is_action_pressed("left"):
		new_direction.x -= 1


	if new_direction != Vector2.ZERO:
		new_direction = new_direction.normalized();
		play_sfx("run");

	direction = new_direction;

	var target_velocity = direction * speed;

	velocity = velocity.linear_interpolate(target_velocity, acceleration);
	velocity = move_and_slide(velocity,Vector2.UP);

# Function to handle physics-based functions.
func _physics_process(_delta: float) -> void:
	follow_mouse();
	update_flip();

# Handle Screen-Shake fallback.
func _process(delta: float) -> void:
	if shakeTimer > 0:
		shakeTimer -= delta;
		var rx = randf() * 3;
		var ry = randf() * 5;
		$Camera2D.offset = Vector2(rx,ry);
	else:
		$Camera2D.offset = Vector2.ZERO;

# Follow mouse function.
func follow_mouse():
	$Hand.look_at(get_global_mouse_position());

# Flip update function.
func update_flip():
	facingRight = get_global_mouse_position().x > global_position.x;
	if facingRight:
		$Hand.position.x = weapon_offset_x
		weapon.flip_v = false;
	else:
		$Hand.position.x = -weapon_offset_x
		weapon.flip_v = true;

	$animation.flip_h = !facingRight;


# Start Screen-Shake event.
func shakeScreen():
	shakeTimer = shakeTime;

# Setter position function.
func setPosition(vec2):
	global_position = vec2;

# Recoil function.
func applyRecoil(direction: Vector2):
	var recoil = -direction * recoil_strength;
	move_and_collide(recoil);

# Shoot event handler functions.
func shoot():
	var bullet = bullet_scene.instance();
	get_parent().add_child(bullet);
	bullet.global_position = muzzle.global_position;
	bullet.direction = (get_global_mouse_position() - bullet.global_position).normalized();
	bullet.rotation = bullet.direction.angle();
	applyRecoil(bullet.direction);
	shakeScreen();
