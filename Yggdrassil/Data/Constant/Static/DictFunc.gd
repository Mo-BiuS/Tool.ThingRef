class_name DictFunc

static func mergeDict(d1:Dictionary,d2:Dictionary)->void:
	for key in d2:
		if(d1.has(key) && d1[key] is Dictionary && d2[key] is Dictionary):mergeDict(d1[key],d2[key])
		else:d1[key] = d2[key]

#==================================================================================================#
static func intAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && (dict[path] is int || dict[path] is float)
static func floatAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && (dict[path] is int || dict[path] is float)
static func stringAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && dict[path] is String
static func fileAt(dict:Dictionary,path:String)->bool:
	if(!stringAt(dict,path)):return false
	if(!FileAccess.file_exists(dict[path])):return false
	return true
#==================================================================================================#
static func dictAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && dict[path] is Dictionary
static func arrayAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && dict[path] is Array
#==================================================================================================#
static func rect2iAt(dict:Dictionary,path:String)->bool:
	if(!dict.has(path) || !(dict[path] is Array)):return false
	var test:Array = dict[path]
	
	if(test.size() != 4):return false
	for i in test:
		if ! (i is int || i is float):return false
	return true
static func getRect2i(dict:Dictionary,path:String)->Rect2i:
	var test:Array = dict[path]
	return Rect2i(test[0],test[1],test[2],test[3])
static func vector2iAt(dict:Dictionary,path:String)->bool:
	if(!dict.has(path) || !(dict[path] is Array)):return false
	var test:Array = dict[path]
	if(test.size() != 2):return false
	for i in test:
		if ! (i is int || i is float):return false
	return true
static func getVector2i(dict:Dictionary,path:String)->Vector2i:
	var test:Array = dict[path]
	return Vector2i(test[0],test[1])
#==================================================================================================#
static func getAtlasIdFromDict(dict:Dictionary)->int:
	if(!dictAt(dict,"atlasData")):return -1
	if(!AtlasLoadData.isValidData(dict["atlasData"])):return -1
	
	return WorldData.textureHandler.getAtlasId(AtlasLoadData.loadDataFrom(dict["atlasData"]))
static func getSpriteFramesIdFromDict(dict:Dictionary)->int:
	if(!dictAt(dict,"spriteFramesData")):return -1
	if(!SpriteFramesLoadData.isValidData(dict["spriteFramesData"])):return -1
	
	return WorldData.textureHandler.getSpriteFramesId(SpriteFramesLoadData.loadDataFrom(dict["spriteFramesData"]))
