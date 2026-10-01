class_name AtlasRequest extends TextureRequest

var rect:Rect2i

static func isValidData(dict:Dictionary)->bool:
	if(!DictFunc.fileAt(dict,"path")):return false
	if(!DictFunc.rect2iAt(dict,"rect")):return false
	return true
static func createRequest(dest:ThingDef,prop:String,dict:Dictionary)->AtlasRequest:
	var rep:=AtlasRequest.new()
	rep.destination = dest
	rep.property = prop
	rep.texturePath = dict["path"]
	rep.rect = DictFunc.getRect2i(dict,"rect")
	rep._genKey()
	return rep

func genAtlas(texture:Texture2D)->AtlasTexture:
	var rep:=AtlasTexture.new()
	rep.region = rect
	rep.atlas = texture
	return rep
func _genKey()->void:
	key = "A:%s:%d,%d,%d,%d" % [texturePath, rect.position.x, rect.position.y, rect.size.x, rect.size.y]
