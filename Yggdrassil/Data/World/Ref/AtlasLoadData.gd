class_name AtlasLoadData extends RefCounted

var texturePath:String
var rect:Rect2i
var key

static func isValidData(dict:Dictionary)->bool:
	if(!DictFunc.fileAt(dict,"path")):return false
	if(!DictFunc.rect2iAt(dict,"rect")):return false
	return true
static func loadDataFrom(dict:Dictionary)->AtlasLoadData:
	var rep:=AtlasLoadData.new()
	rep.texturePath = dict["path"]
	rep.rect = DictFunc.getRect2i(dict,"rect")
	rep._genKey()
	return rep
func _genKey()->void:
	key = "A:%s:%d,%d,%d,%d" % [texturePath, rect.position.x, rect.position.y, rect.size.x, rect.size.y]
