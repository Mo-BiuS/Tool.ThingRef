class_name Yggdrassil extends Node

func  _ready() -> void:
	WorldEvent.stateChanged.connect(_stateChanged)
	WorldState.setState(WorldState.LOADING_RESSOURCE)

func _stateChanged(_old:WorldState.Value,new:WorldState.Value)->void:
	match new:
		WorldState.LOADING_RESSOURCE_FINISHED:
			print("FINISHED")
