class_name ThingDef extends RefCounted

var key:String = ""

var name:String = ""
var descritpion:String = ""

var atlasId:int = -1
var spriteFramesId:int = -1

func setMeta(k:String)->void:
	key = k
func loadFromDict(dict:Dictionary)->bool:
	if(DictFunc.stringAt(dict,"name")):name = dict["name"]
	if(DictFunc.stringAt(dict,"descritpion")):descritpion = dict["descritption"]
	atlasId = WorldData.textureHandler.getAtlasIdFromDict(dict)
	spriteFramesId = WorldData.textureHandler.getSpriteFramesIdFromDict(dict)
	return true

func clear()->void:
	pass
func _to_string() -> String:
	return "[ Thing : "+name+ " \t]"
