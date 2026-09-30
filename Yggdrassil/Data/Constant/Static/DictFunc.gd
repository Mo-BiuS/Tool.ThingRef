class_name DictFunc

static func mergeDict(d1:Dictionary,d2:Dictionary)->void:
	for key in d2:
		if(d1.has(key)):
			if(d1[key] is Dictionary && d2[key] is Dictionary):
				mergeDict(d1[key],d2[key])
			else:
				d1[key] = d2[key]
		else:
			d1[key] = d2[key]

#==================================================================================================#
static func intAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && _isInt(dict[key])
static func floatAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && (dict[key] is int || dict[key] is float)
static func stringAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && dict[key] is String
static func fileAt(dict:Dictionary,key:String)->bool:
	if(!stringAt(dict,key)):return false
	if(!FileAccess.file_exists(dict[key])):return false
	return true
#==================================================================================================#
static func dictAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && dict[key] is Dictionary
static func arrayAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && dict[key] is Array
#==================================================================================================#
static func rect2iAt(dict:Dictionary,key:String)->bool:
	if(!dict.has(key) || !(dict[key] is Array)):return false
	var test:Array = dict[key]

	if(test.size() != 4):return false
	for i in test:
		if ! _isInt(i):return false
	return true
static func getRect2i(dict:Dictionary,key:String)->Rect2i:
	var test:Array = dict[key]
	return Rect2i(test[0],test[1],test[2],test[3])
static func vector2iAt(dict:Dictionary,key:String)->bool:
	if(!dict.has(key) || !(dict[key] is Array)):return false
	var test:Array = dict[key]
	if(test.size() != 2):return false
	for i in test:
		if ! _isInt(i):return false
	return true
static func getVector2i(dict:Dictionary,key:String)->Vector2i:
	var test:Array = dict[key]
	return Vector2i(test[0],test[1])
#==================================================================================================#
static func _isInt(value)->bool:
	return (value is int || (value is float && value == float(int(value))))
