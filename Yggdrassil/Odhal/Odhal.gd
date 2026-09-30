class_name Odhal extends Node

func  _ready() -> void:
	WorldEvent.stateChanged.connect(_stateChanged)
	WorldEvent.setState(E_State.LOADING_RESSOURCE_START)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			print("START")
		E_State.LOADING_RESSOURCE_FINISHED:
			print("FINISHED")
			for t:ThingDef in WorldData.defHandler.root["ThingDef"].values():
				var s:=Sprite2D.new()
				s.texture = WorldData.textureHandler.getAtlas(t.atlasId)
				s.position = Vector2i(randi()%100,randi()%100)
				add_child(s)
