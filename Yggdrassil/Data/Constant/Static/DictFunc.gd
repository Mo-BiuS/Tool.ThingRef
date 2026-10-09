class_name DictFunc

static func mergeDict(base:Dictionary,patch:Dictionary,keyChain:String = "")->Array[String]:
	var overrideReport:Array[String] = []
	for rawKey:String in patch:
		if(rawKey == "tags+"):print(rawKey)
		var key = rawKey
		var arrayMergeRule:=MERGE_TYPE.REPLACE
		if(rawKey.ends_with("+")):
			key = rawKey.trim_suffix("+")
			arrayMergeRule = MERGE_TYPE.APPEND
		elif(rawKey.ends_with("-")):
			key = rawKey.trim_suffix("-")
			arrayMergeRule = MERGE_TYPE.ERASE
		
		if(!base.has(key)):
			if(patch[rawKey] is Dictionary):
				base[key] = {}
				overrideReport.append_array(mergeDict(base[key],patch[rawKey],keyChain+"."+key))
			elif(patch[rawKey] is Array):
				if(arrayMergeRule == MERGE_TYPE.ERASE):base[key] = []
				else:base[key] = patch[rawKey]
			else:
				base[key] = patch[rawKey]
		elif(dictAt(base,key) && dictAt(patch,rawKey)):
			overrideReport.append_array(mergeDict(base[key],patch[rawKey],keyChain+"."+key))
		elif(arrayAt(base,key) && arrayAt(patch,rawKey)):
			match arrayMergeRule:
				MERGE_TYPE.REPLACE:
					base[key] = patch[rawKey].duplicate(true)
					overrideReport.append("[Replaced at \t: %s.%s -> %s]" % [keyChain,key,patch[rawKey]])
				MERGE_TYPE.APPEND:
					base[key].append_array(patch[rawKey])
					overrideReport.append("[Append at \t: %s.%s -> %s]" % [keyChain,key,patch[rawKey]])
				MERGE_TYPE.ERASE:
					for k in patch[rawKey]:base[key].erase(k)
					overrideReport.append("[Erased at \t: %s.%s -> %s]" % [keyChain,key,patch[rawKey]])
		else:
			base[key] = patch[rawKey]
			overrideReport.append("[New value at \t: %s.%s -> %s]" % [keyChain,key,patch[rawKey]])
	return overrideReport
#==================================================================================================#
enum MERGE_TYPE{
	REPLACE=0,
	APPEND=1,
	ERASE=2
}
#==================================================================================================#
static func intAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && _isInt(dict[key])
static func getIntAt(dict:Dictionary,key:String,default:=-1)->int:
	if(!intAt(dict,key)):return default
	return dict[key]

static func floatAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && (dict[key] is int || dict[key] is float)
static func getFloatAt(dict:Dictionary,key:String,default:=-1.)->float:
	if(!floatAt(dict,key)):return default
	return dict[key]

static func stringAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && dict[key] is String
static func getStringAt(dict:Dictionary,key:String,default:="")->String:
	if(!stringAt(dict,key)):return default
	return dict[key]

static func fileAt(dict:Dictionary,key:String)->bool:
	if(!stringAt(dict,key)):return false
	if(!FileAccess.file_exists(dict[key])):return false
	return true
#==================================================================================================#
static func dictAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && dict[key] is Dictionary
static func getDictAt(dict:Dictionary,key:String,default:={})->Dictionary:
	if(!dictAt(dict,key)):return default
	return dict[key]
	
static func arrayAt(dict:Dictionary,key:String)->bool:
	return dict.has(key) && dict[key] is Array
static func getArrayAt(dict:Dictionary,key:String,default:=[])->Array:
	if(!arrayAt(dict,key)):return default
	return dict[key]

static func stringArrayAt(dict:Dictionary,key:String)->bool:
	if(!arrayAt(dict,key)):return false
	var array = getArrayAt(dict,key)
	for value  in array:
		if !value is String : return false
	return true
static func getStringArrayAt(dict:Dictionary,key:String,default:Array[String]=[])->Array[String]:
	if(!stringArrayAt(dict,key)):return default
	var rep:Array[String] = []
	var array = getArrayAt(dict,key)
	for v in array:rep.append(v)
	return rep
#==================================================================================================#
static func rect2iAt(dict:Dictionary,key:String)->bool:
	if(!dict.has(key) || !(dict[key] is Array)):return false
	var test:Array = dict[key]
	if(test.size() != 4):return false
	for i in test:
		if ! _isInt(i):return false
	return true
static func getRect2iAt(dict:Dictionary,key:String,default:=Rect2i(0,0,0,0))->Rect2i:
	if(!rect2iAt(dict,key)):return default
	var test:Array = dict[key]
	return Rect2i(test[0],test[1],test[2],test[3])

static func vector2iAt(dict:Dictionary,key:String)->bool:
	if(!dict.has(key) || !(dict[key] is Array)):return false
	var test:Array = dict[key]
	if(test.size() != 2):return false
	for i in test:
		if ! _isInt(i):return false
	return true
static func getVector2iAt(dict:Dictionary,key:String,default:=Vector2i.ZERO)->Vector2i:
	if(!vector2iAt(dict,key)):return default
	var test:Array = dict[key]
	return Vector2i(test[0],test[1])
#==================================================================================================#
static func _isInt(value)->bool:
	return (value is int || (value is float && value == float(int(value))))
