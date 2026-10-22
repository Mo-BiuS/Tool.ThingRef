class_name ItemDef extends ThingDef

var atlasId:int = -1
var tag:Array[String]

func loadFromDict(dict:Dictionary)->bool:
	if(!super.loadFromDict(dict)):return false
	WorldDef.atlasRequest(self,"atlasId",dict)
	tag = DictFunc.getStringArrayAt(dict,"tags")
	return true
func clear()->void:
	super.clear()
