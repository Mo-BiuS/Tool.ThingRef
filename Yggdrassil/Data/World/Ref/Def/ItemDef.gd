class_name ItemDef extends ThingDef

var atlasId:int = -1

func loadFromDict(dict:Dictionary)->bool:
	if(!super.loadFromDict(dict)):return false
	WorldData.atlasRequest(self,"atlasId",dict)
	return true
