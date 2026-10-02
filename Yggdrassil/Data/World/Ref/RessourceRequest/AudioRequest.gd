class_name AudioRequest extends RessourceRequest

var audioPath:String

static func isValidData(dict:Dictionary)->bool:
	if(!DictFunc.fileAt(dict,"path")):return false
	if(!((dict["path"]).ends_with(".mp3") || (dict["path"]).ends_with(".ogg"))):return false
	return true
static func createRequest(dest:AudioDef,prop:String,dict:Dictionary)->AudioRequest:
	var rep:=AudioRequest.new()
	rep.property = prop
	rep.destination = dest
	rep.audioPath = DictFunc.getStringAt(dict,"path")
	rep._genKey()
	return rep

func _genKey()->void:
	key = audioPath
