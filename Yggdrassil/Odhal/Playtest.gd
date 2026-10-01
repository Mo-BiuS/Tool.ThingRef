class_name Playtest extends Node2D

@export var testingSpawn:Node2D

func startTest()->void:
	for t:ThingDef in WorldData.getDefCategories(ThingDef).values():
		if(t.atlasId != -1):
			var s:=Sprite2D.new()
			s.texture = WorldData.getAtlasFromId(t.atlasId)
			s.position = Vector2i(randi()%360-180,randi()%360-180)
			testingSpawn.add_child(s)
		if(t.spriteFramesId != -1):
			var sf = WorldData.getSpriteFramesFromId(t.spriteFramesId)
			for n:String in sf.get_animation_names():
				var s:=AnimatedSprite2D.new()
				s.sprite_frames = sf
				s.play(n)
				s.position = Vector2i(randi()%360-180,randi()%360-180)
				testingSpawn.add_child(s)

func clear()->void:
	for i in testingSpawn.get_children():i.queue_free()
