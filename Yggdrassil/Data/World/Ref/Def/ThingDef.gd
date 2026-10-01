class_name ThingDef extends Def

var name:String = ""
var description:String = ""

var atlasId:int = -1
var spriteFramesId:int = -1

func loadFromDict(dict:Dictionary)->bool:
	name = DictFunc.getStringAt(dict,"name")
	description = DictFunc.getStringAt(dict,"description")
	
	WorldData.atlasRequest(self,"atlasId",dict)
	WorldData.spriteFrameRequest(self,"spriteFramesId",dict)
	return true

func clear()->void:
	pass
func _to_string() -> String:
	return "[ Thing : "+name+ " \t]"
