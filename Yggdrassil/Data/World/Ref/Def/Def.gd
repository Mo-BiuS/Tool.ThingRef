@abstract class_name Def extends RefCounted

var key:String = ""
var source:Array[String] = []
func setMeta(k:String)->void:
	key = k

func loadFromDict(dict:Dictionary)->bool:
	source = DictFunc.getStringArrayAt(dict,"Sources")
	print(source)
	return true
@abstract func clear()->void
