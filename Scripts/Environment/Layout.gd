extends Node2D
onready var player := $Player;
onready var tilemap := $TileMap;
onready var lootbox := preload("res://Props/LootBox/Loot.tscn");

func addLootBox(pos: Vector2):
	var lootBox := lootbox.instance();
	lootBox.global_position = pos;
	add_child(lootBox);

func _ready() -> void:
	player.setPosition(tilemap.getRandomPos());
	for i in range(10):
		addLootBox(tilemap.getRandomPos());

