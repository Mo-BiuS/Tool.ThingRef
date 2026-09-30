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
			if(WorldData.defHandler.root.has("ThingDef")):
				for t:ThingDef in WorldData.defHandler.root["ThingDef"].values():
					if(t.atlasId != -1):
						var s:=Sprite2D.new()
						s.texture = WorldData.textureHandler.getAtlas(t.atlasId)
						s.position = Vector2i(randi()%400-200,randi()%400-200)
						add_child(s)
					if(t.spriteFramesId != -1):
						var sf = WorldData.textureHandler.getSpriteFrames(t.spriteFramesId)
						for n:String in sf.get_animation_names():
							var s:=AnimatedSprite2D.new()
							s.sprite_frames = sf
							s.play(n)
							s.position = Vector2i(randi()%400-200,randi()%400-200)
							add_child(s)
