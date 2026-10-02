class_name DefHandler extends RessourceHandler

const LOAD_LIST:="res://LoadList.json"

var defLoadOrder:Array[GDScript] = [
	ItemDef,
	PlayerDef,
	AudioDef
]
var mergeRule:=DictFunc.MergeRule.new()
var root:Dictionary[GDScript,Dictionary]

func init()->void:
	source = "DefHandler"
	mergeRule.rule["Sources"] = DictFunc.MERGE_TYPE.APPEND
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
		var sourceDict:=_getDictFromFolder(path)
		appendSource(sourceDict,sourceName)
		appendPath(sourceDict,path)
		var report:Array[String] = DictFunc.mergeDict(rep,sourceDict,mergeRule,sourceName)
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
		_putWarning("Def dict not empty %s" % allDict)

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
func _getDictFromFolder(path:String)->Dictionary:
	var dir = DirAccess.open(path)
	if(dir == null):
		_putError("Dir not found : %s" % path)
		return {}
	
	var rep:Dictionary = {}
	
	dir.list_dir_begin()
	var fileName = dir.get_next()
	while fileName != "":
		if dir.current_is_dir():
			DictFunc.mergeDict(rep,_getDictFromFolder(path.path_join(fileName)))
		elif(fileName.ends_with(".json")):
			DictFunc.mergeDict(rep,_loadJsonFromPath(path.path_join(fileName)))
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
func appendSource(dict:Dictionary,name:String)->void:
	for script in defLoadOrder:
		for def in DictFunc.getDictAt(dict,script.get_global_name()).values():
			if(def is Dictionary):
				if(DictFunc.arrayAt(def,"Sources")):def["Sources"].append(name)
				else:def["Sources"] = [name]
func appendPath(dict:Dictionary,path:String)->void:
	if(DictFunc.stringAt(dict,"path")):dict["path"] = path.path_join(dict["path"])
	else:
		for key in dict.keys():
			if(DictFunc.dictAt(dict,key)):appendPath(dict[key],path)
func clear()->void:
	root.clear()
func exit()->void:
	if _loadingThread != null && _loadingThread.is_started():
		_loadingThread.wait_to_finish()
