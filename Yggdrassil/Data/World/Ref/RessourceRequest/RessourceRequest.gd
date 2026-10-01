@abstract class_name RessourceRequest extends RefCounted

var destination:ThingDef
var property:String
var key:String

@abstract func _genKey()->void
