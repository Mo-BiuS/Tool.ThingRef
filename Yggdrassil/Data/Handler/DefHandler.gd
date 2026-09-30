class_name DefHandler extends Node

var _loadingThread:Thread

const CORE_FOLDER:="res://Data/Core/"

var root:Dictionary[String,Dictionary]

func _ready() -> void:
	WorldEvent.stateChanged.connect(_stateChanged)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			clear()
			_loadingThread = Thread.new()
			_loadingThread.start(_loading)

#==============================================================================#
func _loading()->void:
	_loadRefInFolder(CORE_FOLDER)
	WorldEvent.setState(E_State.LOADING_RESSOURCE_FINISHED)

func _loadRefInFolder(path:String)->void:
	var dir = DirAccess.open(path)
	if(dir == null):return
	
	var allDict:Dictionary = _getDictFromFolder(path+"Ref")
	if(!allDict.is_empty()):
		var sourceName:=path.get_slice("/",path.get_slice_count("/")-2)
		root["ThingDef"] = {}
		_loadThingDef(allDict,sourceName)

func _loadThingDef(dict:Dictionary,sourceName:String)->void:
	if(DictFunc.dictAt(dict,"ThingDef")):
		root["ThingDef"] = {}
		for key in dict["ThingDef"].keys():
			var thing:=ThingDef.new()
			thing.setMeta(key,sourceName)
			thing.loadFromDict(dict["ThingDef"][key])
			root["ThingDef"][key] = thing
		dict.erase("ThingDef")

#==============================================================================#
func _getDictFromFolder(path:String)->Dictionary:
	var dir = DirAccess.open(path)
	if(dir == null):return {}
	
	var rep:Dictionary = {}
	
	dir.list_dir_begin()
	var fileName = dir.get_next()
	while fileName != "":
		if dir.current_is_dir():
			DictFunc.mergeDict(rep,_getDictFromFolder(path+"/"+fileName))
		elif(fileName.ends_with(".json")):
			var json_as_text = FileAccess.get_file_as_string(path+"/"+fileName)
			var parsedData=JSON.parse_string(json_as_text)
			if(parsedData != null && parsedData is Dictionary):
				DictFunc.mergeDict(rep,JSON.parse_string(json_as_text))
		fileName = dir.get_next()
	
	return rep

func clear()->void:
	pass
