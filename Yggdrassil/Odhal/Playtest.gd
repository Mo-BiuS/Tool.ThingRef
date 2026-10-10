class_name Playtest extends Node2D

@export var testingSpawn:Node2D

func startTest()->void:
	for t:TileSetDef in WorldData.getDefCategories(TileSetDef).values():
		if(t.tileSetId != -1):
			var ts = WorldData.getTileSetFromId(t.tileSetId)
			var tml := TileMapLayer.new()
			tml.tile_set = ts
			var connectCells:Array[Vector2i] = []
			
			var paintable:Array[int] = []
			for i in BetterTerrain.terrain_count(ts):
				if(BetterTerrain.get_terrain(ts,i)["type"] == BetterTerrain.TerrainType.MATCH_TILES):
					paintable.append(i)
			if(!paintable.is_empty()):
				paintable.append(-1)
				for x in range(-20,20):
					for y in range(-20,20):
						var pos:=Vector2i(x,y)
						BetterTerrain.set_cell(tml,pos,paintable.pick_random())
						connectCells.append(pos)
				BetterTerrain.update_terrain_cells(tml,connectCells)
				tml.z_index = -1
				testingSpawn.add_child(tml)
	for t:PlayerDef in WorldData.getDefCategories(PlayerDef).values():
		if(t.spriteFramesId != -1):
			var sf = WorldData.getSpriteFramesFromId(t.spriteFramesId)
			for n:String in sf.get_animation_names():
				var s:=AnimatedSprite2D.new()
				s.sprite_frames = sf
				s.play(n)
				s.position = Vector2i(randi()%360-180,randi()%360-180)
				testingSpawn.add_child(s)
	for t:ItemDef in WorldData.getDefCategories(ItemDef).values():
		if(t.atlasId != -1):
			var s:=Sprite2D.new()
			s.texture = WorldData.getAtlasFromId(t.atlasId)
			s.position = Vector2i(randi()%360-180,randi()%360-180)
			testingSpawn.add_child(s)
	for t:AudioDef in WorldData.getDefCategories(AudioDef).values():
		if(t.audioId != -1):
			var s:=AudioStreamPlayer2D.new()
			s.stream = WorldData.getAudioFromId(t.audioId)
			s.autoplay = true
			s.position = Vector2i(randi()%360-180,randi()%360-180)
			testingSpawn.add_child(s)

func clear()->void:
	for i in testingSpawn.get_children():i.queue_free()
