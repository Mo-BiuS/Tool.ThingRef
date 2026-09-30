class_name ThingDef extends RefCounted

var key:String = ""
var source:String = ""

var name:String = ""
var descritpion:String = ""

var atlasId:int = -1
var spriteFramesId:int = -1

func setMeta(k:String, s:String)->void:
	key = k
	source = s

func loadFromDict(dict:Dictionary)->bool:
	if(DictFunc.stringAt(dict,"name")):name = dict["name"]
	if(DictFunc.stringAt(dict,"descritpion")):descritpion = dict["descritpion"]
	atlasId = DictFunc.getAtlasIdFromDict(dict)
	spriteFramesId = DictFunc.getSpriteFramesIdFromDict(dict)
	return true

func clear()->void:
	pass
func _to_string() -> String:
	return "[ Thing : "+name+ " \t][ Source:"+source+" ]\n"
