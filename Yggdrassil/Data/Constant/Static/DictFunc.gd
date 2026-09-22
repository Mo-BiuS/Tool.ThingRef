class_name DictFunc

static func mergeDict(d1:Dictionary,d2:Dictionary)->void:
	for key in d2:
		if(d1.has(key) && d1[key] is Dictionary && d2[key] is Dictionary):mergeDict(d1[key],d2[key])
		else:d1[key] = d2[key]

static func stringAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && dict[path] is String
static func dictAt(dict:Dictionary,path:String)->bool:
	return dict.has(path) && dict[path] is Dictionary
