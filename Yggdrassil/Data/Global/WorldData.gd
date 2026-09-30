extends Node

var defHandler:=DefHandler.new()
var textureHandler:=TextureHandler.new()

func _ready() -> void:
	add_child(defHandler)
	add_child(textureHandler)
	WorldEvent.stateChanged.connect(_stateChanged)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			defHandler.clear()
			textureHandler.clear()
			defHandler.startLoading()
