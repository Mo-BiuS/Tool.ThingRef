class_name PlayerDef extends ThingDef

var spriteFramesId:int = -1

func loadFromDict(dict:Dictionary)->bool:
	if(!super.loadFromDict(dict)):return false
	WorldData.spriteFrameRequest(self,"spriteFramesId",dict)
	return true
