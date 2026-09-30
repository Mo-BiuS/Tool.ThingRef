class_name SpriteFramesLoadData extends RefCounted

var texturePath:String
var frameSize:Vector2i
var animDict:Dictionary[String,Array]
var key:String

static func isValidData(dict:Dictionary)->bool:
	if(!DictFunc.fileAt(dict,"path")):return false
	if(!DictFunc.vector2iAt(dict,"frameSize")):return false
	if(!DictFunc.dictAt(dict,"animations")):return false
	var animTestDict:Dictionary = dict["animations"]
	if(animTestDict.is_empty()):return false
	for animKey in animTestDict.keys():
		if(!(animKey is String && animTestDict[animKey] is Array && ArrayFunc.vector2iArrayAt(animTestDict[animKey]))):return false
	return true
static func loadDataFrom(dict:Dictionary)->SpriteFramesLoadData:
	var rep:=SpriteFramesLoadData.new()
	rep.texturePath = dict["path"]
	rep.frameSize = DictFunc.getVector2i(dict,"frameSize")
	var subDict:Dictionary=dict["animations"]
	for animKey:String in subDict.keys():
		rep.animDict[animKey] = ArrayFunc.getVector2iArrayAt(subDict[animKey])
	rep._genKey()
	return rep

func genSpriteFrames(texture:Texture2D)->SpriteFrames:
	var rep := SpriteFrames.new()
	rep.remove_animation(&"default")
	for animName:String in animDict.keys():
		rep.add_animation(animName)
		for pos:Vector2i in animDict[animName]:
			var frame:=AtlasTexture.new()
			frame.region = Rect2i(pos*frameSize,frameSize)
			frame.atlas = texture
			rep.add_frame(animName,frame)
	return rep

func _genKey()->void:
	key="S:%s:%d:%d" % [texturePath,frameSize.x, frameSize.y]
	for animKey:String in animDict.keys():
		key+="|%s" % animKey
		for pos:Vector2i in animDict[animKey]:
			key+=":%d:%d" % [pos.x, pos.y]
