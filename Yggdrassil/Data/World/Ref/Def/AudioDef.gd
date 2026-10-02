class_name AudioDef extends Def

var audioId:int = -1

func loadFromDict(dict:Dictionary)->bool:
	if(!super.loadFromDict(dict)):return false
	WorldData.audioRequest(self,"audioId",dict)
	return true
func clear()->void:
	pass
