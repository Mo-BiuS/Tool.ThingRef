@abstract class_name Def extends RefCounted

var key:String = ""
var sources:Array[String] = []
func setMeta(k:String)->void:
	key = k

func loadFromDict(dict:Dictionary)->bool:
	sources = DictFunc.getStringArrayAt(dict,"Sources")
	return true
@abstract func clear()->void
