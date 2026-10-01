@abstract class_name Def extends RefCounted

var key:String = ""
func setMeta(k:String)->void:
	key = k

@abstract func loadFromDict(dict:Dictionary)->bool
@abstract func clear()->void
