extends StaticBody2D

onready var guns_scene :=preload("res://Props/Guns/Guns.tscn");
var guns := [];

func _ready() -> void:
	randomize();
	var guns_instance := guns_scene.instance();
	guns = guns_instance.get_children();
	var randomVal = randi() % guns.size();
	var gun = guns[randomVal].duplicate();
	$LootGun.add_child(gun);
	gun.position = Vector2.ZERO;

	guns_instance.queue_free();

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		$Sprite.play("IDLE");
