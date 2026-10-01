class_name ThingDef extends RefCounted

var key:String = ""

var name:String = ""
var description:String = ""

var atlasId:int = -1
var spriteFramesId:int = -1

func setMeta(k:String)->void:
	key = k
func loadFromDict(dict:Dictionary)->bool:
	if(DictFunc.stringAt(dict,"name")):name = dict["name"]
	if(DictFunc.stringAt(dict,"description")):description = dict["description"]
	
	WorldData.atlasRequest(self,"atlasId",dict)
	WorldData.spriteFrameRequest(self,"spriteFramesId",dict)
	return true

func clear()->void:
	pass
func _to_string() -> String:
	return "[ Thing : "+name+ " \t]"
