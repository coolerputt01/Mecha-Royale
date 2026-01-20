extends TileMap

enum GRID_SPACE {
	EMPTY,
	FLOOR,
	WALL
}
var TILE_ID = {
	"FLOOR" : 2,
	"WALL" : 3,
}
var gridMap = [];
export var map_width := 15;
export var map_height := 15;
var walkers := [];

var chanceWalkerChangeDir := 0.7;
var chanceWalkerSpawn := 0.1;
var chanceToDestroy := 0.05;
var maxWalkers := 10;
var percentToFill := 0.2;

func _ready() -> void:
	randomize();
	setupMap();
	createFloorTiles();
	createWallTiles();
	spawnLevel();

func randomDirection():
	var choice = randi() % 4;
	match(choice):
		0:
			return Vector2.DOWN;
		1:
			return Vector2.LEFT;
		2:
			return Vector2.UP;
		_:
			return Vector2.RIGHT;

func numberOfFloors():
	var count = 0;
	for y in range(map_height):
		for x in range(map_width):
			if gridMap[y][x] == GRID_SPACE.FLOOR:
				count += 1;
	return count;

func setupMap():
	walkers.clear();
	gridMap.clear();
	#clear();
	for y in range(map_height):
		gridMap.append([]);
		for x in range(map_width):
			gridMap[y].append(GRID_SPACE.EMPTY);

	walkers.append({
		"pos": Vector2(int(map_width/2),int(map_height/2)),
		"dir": randomDirection(),
		});

func createFloorTiles():
	var iterations = 60;
	for i in range(iterations):
		for walker in walkers:
			gridMap[int(walker["pos"].y)][int(walker["pos"].x)] = GRID_SPACE.FLOOR;

		var numberOfChecks = 5;
		for j in range(numberOfChecks):
			if randf() < chanceToDestroy and walkers.size() > 1:
				walkers.pop_at(randi() % walkers.size())
				break;

		for walker in walkers:
			if randf() < chanceWalkerChangeDir:
				walker["dir"] = randomDirection();

		numberOfChecks = walkers.size();
		for l in range(numberOfChecks):
			if randf() < chanceWalkerSpawn and walkers.size() < maxWalkers:
				walkers.append({
					"pos": walkers[l]["pos"],
					"dir": randomDirection(),
				});

		for walker in walkers:
			walker["pos"] += walker["dir"];

		for walker in walkers:
			walker["pos"].x = clamp(walker["pos"].x,1,map_width - 2);
			walker["pos"].y = clamp(walker["pos"].y,1,map_height - 2);

		if float(numberOfFloors())/ float(map_width * map_height) > percentToFill:
			break;

func createWallTiles():
	for y in range(map_height):
		for x in range(map_height):
			if gridMap[y][x] == GRID_SPACE.FLOOR:
				if gridMap[y][x+1] == GRID_SPACE.EMPTY:
					gridMap[y][x+1] = GRID_SPACE.WALL;
				if gridMap[y][x-1] == GRID_SPACE.EMPTY:
					gridMap[y][x-1] = GRID_SPACE.WALL;
				if gridMap[y+1][x] == GRID_SPACE.EMPTY:
					gridMap[y+1][x] = GRID_SPACE.WALL
				if gridMap[y-1][x] == GRID_SPACE.EMPTY:
					gridMap[y-1][x] = GRID_SPACE.WALL

func spawn(x,y,tileID):
	set_cell(x,y,tileID);

func getRandomPos():
	randomize();
	var floor_data := [];
	for y in map_height:
		for x in map_width:
			if gridMap[y][x] == GRID_SPACE.FLOOR:
				floor_data.append(Vector2(x,y));

	if floor_data.empty():
		return to_global(map_to_world(walkers.front()["pos"]) + cell_size / 2)
		print("hi")

	var tile = floor_data[randi() % floor_data.size()];
	var world_mapped = map_to_world(tile);
	world_mapped += cell_size / 2;
	return to_global(world_mapped);

func spawnLevel():
	for y in range(map_height):
		for x in range(map_width):
			match(gridMap[y][x]):
				GRID_SPACE.FLOOR:
					spawn(x,y,TILE_ID["FLOOR"]);
				GRID_SPACE.WALL:
					spawn(x,y,TILE_ID["WALL"])
