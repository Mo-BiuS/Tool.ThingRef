class_name Odhal extends Node

@export var playtest:Playtest

func  _ready() -> void:
	WorldEvent.stateChanged.connect(_stateChanged)
	WorldEvent.setState(E_State.LOADING_RESSOURCE_START)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			print("START")
		E_State.LOADING_RESSOURCE_FINISHED:
			print("FINISHED")
			playtest.startTest()
