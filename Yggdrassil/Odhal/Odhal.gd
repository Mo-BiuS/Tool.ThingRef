class_name Odhal extends Node

@export var playtest:Playtest

func  _ready() -> void:
	WorldEvent.stateChanged.connect(_stateChanged)
	WorldDef.finishedLoading.connect(_finishedLoading)
	
	WorldDef.appendDef(TileSetDef)
	WorldDef.appendDef(ItemDef)
	WorldDef.appendDef(PlayerDef)
	WorldDef.appendDef(AudioDef)
	
	WorldEvent.setState(E_State.LOADING_RESSOURCE_START)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			WorldDef.startLoading()
		E_State.LOADING_RESSOURCE_FINISHED:
			playtest.startTest()

func _finishedLoading():
	WorldEvent.setState(E_State.LOADING_RESSOURCE_FINISHED)
