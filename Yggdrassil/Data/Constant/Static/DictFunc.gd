class_name DictFunc

static func mergeDict(d1:Dictionary,d2:Dictionary,mergeRule:MergeRule=MergeRule.new(),keyChain:String = "")->Array[String]:
	var overrideReport:Array[String] = []
	for key in d2:
		if(d1.has(key)):
			if(d1[key] is Dictionary && d2[key] is Dictionary):
				overrideReport.append_array(mergeDict(d1[key],d2[key],mergeRule,keyChain+"."+key))
			else:
				if(arrayAt(d1,key) && arrayAt(d2,key)):
					var rule:=mergeRule.default
					if(mergeRule.rule.has(key)):rule = mergeRule.rule[key]
					match rule:
						MERGE_TYPE.REPLACE:d1[key] = d2[key]
						MERGE_TYPE.APPEND:d1[key].append_array(d2[key])
				else:
					d1[key] = d2[key]
				overrideReport.append("[At : %s.%s -> New : %s]" % [keyChain,key,d2[key]])
		else:
			d1[key] = d2[key]
	return overrideReport
#==================================================================================================#
class MergeRule:
	var default:=MERGE_TYPE.REPLACE
	var rule:Dictionary[String,MERGE_TYPE]
enum MERGE_TYPE{
	REPLACE,
	APPEND
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
static func getStringArrayAt(dict:Dictionary,key:String,default:=[])->Array[String]:
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
