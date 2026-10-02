class_name ThingDef extends Def

var name:String = ""
var description:String = ""

func loadFromDict(dict:Dictionary)->bool:
	if(!super.loadFromDict(dict)):return false
	name = DictFunc.getStringAt(dict,"name")
	description = DictFunc.getStringAt(dict,"description")
	
	return true

func clear()->void:
	pass
