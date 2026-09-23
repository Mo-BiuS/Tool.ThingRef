class_name DictFunc

static func mergeDict(d1:Dictionary,d2:Dictionary)->void:
	for key in d2:
		if(d1.has(key) && d1[key] is Dictionary && d2[key] is Dictionary):mergeDict(d1[key],d2[key])
		else:d1[key] = d2[key]

static func stringAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && dict[path] is String
static func dictAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && dict[path] is Dictionary
static func arrayAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && dict[path] is Array
static func rect2iAt(dict:Dictionary,path:String)->bool:
	if(!dict.has(path) || !(dict[path] is Array)):return false
	var test:Array = dict[path]
	if(test.size() != 4):return false
	for i in test:
		if ! i is int:return false
	return true

static func getRect2i(dict:Dictionary,path:String)->Rect2i:
	var test:Array = dict[path]
	return Rect2i(test[0],test[1],test[2],test[3])
	
static func getAtlasIdFromDict(dict:Dictionary)->int:
	if(!dictAt(dict,"atlasData")):return -1
	
	var atlasDict:Dictionary=dict["atlasData"]
	if(!stringAt(atlasDict,"path")):return -1
	if(!rect2iAt(atlasDict,"rect")):return -1
	
	return WorldData.textureHandler.getAtlasId(atlasDict["path"],getRect2i(atlasDict,"rect"))
