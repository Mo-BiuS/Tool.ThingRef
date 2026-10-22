class_name TileSetDef extends Def

var tileSetId:int = -1

func loadFromDict(dict:Dictionary)->bool:
	if(!super.loadFromDict(dict)):return false
	
	WorldDef.tileSetRequest(self,"tileSetId",dict)
	
	return true

func clear()->void:
	pass
