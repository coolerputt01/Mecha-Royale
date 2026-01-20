extends KinematicBody2D

export var speed := 200;
export var acceleration := 0.7;

var direction := Vector2.ZERO;
var velocity := Vector2.ZERO;

onready var bullet_scene := preload("res://Props/Bullet/Bullet.tscn");
onready var label := $Control/StatesLabel;
onready var weapon := $Hand/Gun/Sprite;
onready var sfx_shoot := preload("res://Assets/Music/SFX/shoot-6-81136.mp3")
onready var sfx_run := preload("res://Assets/Music/SFX/st2-footstep-sfx-323055.mp3")
onready var sfx := $sfx;
#onready var crosshair := $Crosshair;
var weapon_offset_x := 3;
var bullet_offset := Vector2(13,13);
var recoil_strength := 3;

var facingRight = true;

var shakeTimer := 0.0;
var shakeTime := 0.1;
var delt;
var isMoving = true;

func play_sfx(stream):
	randomize();
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

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if event is InputEventMouseButton:
		shoot();
		play_sfx("shoot");

func setStateLabel(txt : String):
	$Control/StatesLabel.bbcode_text = txt;

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


func _physics_process(delta: float) -> void:
	delt = delta;
	follow_mouse();
	update_flip();

func _process(delta: float) -> void:
	if shakeTimer > 0:
		shakeTimer -= delta;
		var rx = randf() * 3;
		var ry = randf() * 5;
		$Camera2D.offset = Vector2(rx,ry);
	else:
		$Camera2D.offset = Vector2.ZERO;


func follow_mouse():
	$Hand.look_at(get_global_mouse_position());

func update_flip():
	facingRight = get_global_mouse_position().x > global_position.x;
	#weapon.flip_h = not facingRight
	if facingRight:
		$Hand.position.x = weapon_offset_x
		weapon.flip_v = false;
	else:
		$Hand.position.x = -weapon_offset_x
		weapon.flip_v = true;

	$animation.flip_h = !facingRight;


func shakeScreen():
	shakeTimer = shakeTime;

func setPosition(vec2):
	global_position = vec2;

func applyRecoil(direction: Vector2):
	var recoil = -direction * recoil_strength;
	move_and_collide(recoil);

func shoot():
	var bullet = bullet_scene.instance();
	get_parent().add_child(bullet);
	bullet.global_position = $Hand/Gun/Muzzle.global_position;
	bullet.direction = (get_global_mouse_position() - bullet.global_position).normalized();
	bullet.rotation = bullet.direction.angle();
	applyRecoil(bullet.direction);
	shakeScreen();
