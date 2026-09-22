extends Node

@warning_ignore("unused_signal") signal stateChanged(old:E_State.Value, new:E_State.Value)

var state := E_State.NONE
var message:=""

func setState(newState:E_State.Value)->void:
	call_deferred("_st",newState)
func _st(ns:E_State.Value)->void:
	if(ns != state):
		var oldState = state
		state = ns
		WorldEvent.stateChanged.emit(oldState, ns)
