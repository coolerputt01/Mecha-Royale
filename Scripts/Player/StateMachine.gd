extends "res://Scripts/Character/StateMachine.gd"

# Ready callback.
func _ready() -> void:
	addState("IDLE");
	addState("MOVE");
	addState("SHOOT");
	addState("BLINK");
	call_deferred("setState","IDLE");

	parent.get_node("animation").play("IDLE");
	parent.setStateLabel("IDLE");
	parent.isMoving = true;
	parent.get_node("animation").flip_h = false;

# Function to handle states logic
func stateLogic(delta):
	if state == states.MOVE:
		parent.handleMovement(delta);

func getTransition():
	if (Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		return states.MOVE;
	else:
		return states.IDLE;

# Manage enter state.
func enterState(state,oldState):
	match state:
		"IDLE":
			parent.get_node("animation").play("IDLE");
		"MOVE":
			parent.get_node("animation").play("MOVE");
			parent.get_node("Hand/Gun/animation").play("MOVE");
		"SHOOT":
			parent.get_node("animation").play("SHOOT");
		"BLINK":
			parent.get_node("animation").play("BLINK");
			parent.shakeScreen();

	parent.setStateLabel(state);

# Exit state.
func exitState(oldState,newState):
	pass;
