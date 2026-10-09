class_name DefHandler extends RessourceHandler

const LOAD_LIST:="res://LoadList.json"

var defLoadOrder:Array[GDScript] = [
	ItemDef,
	PlayerDef,
	AudioDef
]
var root:Dictionary[GDScript,Dictionary]

func init()->void:
	source = "DefHandler"
#==============================================================================#
func startLoading()->void:
	_loadingThread = Thread.new()
	_loadingThread.start(_loading)
func _loading()->void:
	_loadDefFromDict(_loadAllDict())
	call_deferred("_endLoading")
func _endLoading()->void:
	if _loadingThread != null && _loadingThread.is_started():
		_loadingThread.wait_to_finish()
	finishedLoading.emit()

func _loadAllDict()->Dictionary:
	var rep := {}
	var loadDict:=_loadJsonFromPath(LOAD_LIST)
	var loadArray:Array = DictFunc.getArrayAt(loadDict,"LoadList")
	for path:String in loadArray:
		var sourceName:=path.trim_suffix("/").get_file()
		var sourceList:=_getDictFromFolder(path)
		for sourceDict:Dictionary in sourceList:
			appendSource(sourceDict,sourceName)
			sourceDict = resolvePaths(sourceDict,path)
			var report:Array[String] = mergeRefDict(rep,sourceDict,path,sourceName)
			for m:String in report:
				_putMessage("DEF EDITED -> %s" % m)
	return rep

func _loadDefFromDict(allDict:Dictionary)->void:
	for script in defLoadOrder:
		var scriptName := script.get_global_name()
		root[script] = {}
		var scriptDict:Dictionary = DictFunc.getDictAt(allDict,scriptName)
		for key in scriptDict.keys():
			if(DictFunc.dictAt(scriptDict,key)):
				var thing:Def=script.new()
				thing.setMeta(key)
				if(thing.loadFromDict(scriptDict[key])):
					root[script][key] = thing
		allDict.erase(scriptName)
	
	if(!allDict.is_empty()):
		_putWarning("Def dict not empty :\n%s" % allDict)

#==============================================================================#
func getDefCategories(script:GDScript)->Dictionary:
	var rep:Dictionary = {}
	for key in root:
		var current:GDScript = key

		while current != null:
			if current == script:
				DictFunc.mergeDict(rep,root[key])
			current = current.get_base_script()
	
	return rep
#==============================================================================#
func _getDictFromFolder(path:String)->Array[Dictionary]:
	var dir = DirAccess.open(path)
	if(dir == null):
		_putError("Dir not found : %s" % path)
		return []
	
	var rep:Array[Dictionary] = []
	
	dir.list_dir_begin()
	var fileName = dir.get_next()
	while fileName != "":
		if dir.current_is_dir():
			rep.append_array(_getDictFromFolder(path.path_join(fileName)))
		elif(fileName.ends_with(".json")):
			rep.append(_loadJsonFromPath(path.path_join(fileName)))
		fileName = dir.get_next()
	dir.list_dir_end()
	return rep

func _loadJsonFromPath(path:String)->Dictionary:
	if !FileAccess.file_exists(path) :
		_putError("File not found : %s" % path)
		return {}
	var json := JSON.new()
	if(json.parse(FileAccess.get_file_as_string(path)) != OK):
		_putError("%s ligne %d : %s" % [path, json.get_error_line(), json.get_error_message()])
	elif(json.data is Dictionary):
		return json.data
	return {}
#==============================================================================#
static func mergeRefDict(base:Dictionary,patch:Dictionary,path:String,keyChain:String)->Array[String]:
	var overrideReport:Array[String] = []
	for rawKey:String in patch:
		var key = rawKey
		var arrayMergeRule:=DictFunc.MERGE_TYPE.REPLACE
		if(rawKey.ends_with("+")):
			key = rawKey.trim_suffix("+")
			arrayMergeRule = DictFunc.MERGE_TYPE.APPEND
		elif(rawKey.ends_with("-")):
			key = rawKey.trim_suffix("-")
			arrayMergeRule = DictFunc.MERGE_TYPE.ERASE
		
		if(!base.has(key)):
			if(patch[rawKey] is Dictionary):
				base[key] = {}
				overrideReport.append_array(mergeRefDict(base[key],patch[rawKey],path,keyChain+"."+key))
			elif(patch[rawKey] is Array):
				if(arrayMergeRule == DictFunc.MERGE_TYPE.ERASE):base[key] = []
				else:base[key] = patch[rawKey]
			else:
				base[key] = patch[rawKey]
		elif(DictFunc.dictAt(base,key) && DictFunc.dictAt(patch,rawKey)):
			match arrayMergeRule:
				DictFunc.MERGE_TYPE.ERASE:
					base.erase(key)
					overrideReport.append("[Erased at \t: %s.%s]" % [keyChain,key])
				_:
					overrideReport.append_array(mergeRefDict(base[key],patch[rawKey],path,keyChain+"."+key))
		elif(DictFunc.arrayAt(base,key) && DictFunc.arrayAt(patch,rawKey)):
			match arrayMergeRule:
				DictFunc.MERGE_TYPE.REPLACE:
					base[key] = patch[rawKey]
					overrideReport.append("[Replaced at \t: %s.%s -> %s]" % [keyChain,key,patch[rawKey]])
				DictFunc.MERGE_TYPE.APPEND:
					base[key].append_array(patch[rawKey])
					overrideReport.append("[Append at \t: %s.%s -> %s]" % [keyChain,key,patch[rawKey]])
				DictFunc.MERGE_TYPE.ERASE:
					for k in patch[rawKey]:base[key].erase(k)
					overrideReport.append("[Erased at \t: %s.%s -> %s]" % [keyChain,key,patch[rawKey]])
		else:
			base[key] = patch[rawKey]
			overrideReport.append("[New value at \t: %s.%s -> %s]" % [keyChain,key,patch[rawKey]])
	return overrideReport
static func resolvePaths(value:Variant, path:String)->Variant:
	if(value is Dictionary):
		var out := {}
		for rawKey:String in value:
			var k := rawKey
			var op := ""
			if(k.ends_with("+") || k.ends_with("-")):
				op = k.right(1)
				k = k.left(-1)
			var v = resolvePaths(value[rawKey], path)
			if(k.ends_with("~")):
				k = k.trim_suffix("~")
				v = _joinPath(v, path)
			out[k + op] = v
		return out
	elif(value is Array):
		return value.map(func(e): return resolvePaths(e, path))
	return value
static func _joinPath(v:Variant, path:String)->Variant:
	if(v is String):
		return path.path_join(v)
	if(v is Array):return v.map(func(e): return path.path_join(e) if e is String else e)
	return v
func appendSource(dict:Dictionary,name:String)->void:
	for script in defLoadOrder:
		for def in DictFunc.getDictAt(dict,script.get_global_name()).values():
			if(def is Dictionary):
				if(DictFunc.arrayAt(def,"Sources+")):def["Sources+"].append(name)
				else:def["Sources+"] = [name]
func clear()->void:
	root.clear()
func exit()->void:
	if _loadingThread != null && _loadingThread.is_started():
		_loadingThread.wait_to_finish()
