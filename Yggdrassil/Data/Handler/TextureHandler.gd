class_name TextureHandler extends Node

var pathToId:Dictionary[String,int] = {}
var textureArray:Array[Texture2D] = []
var mutex:=Mutex.new()

func _ready() -> void:
	WorldEvent.stateChanged.connect(_stateChanged)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			clear()

func clear()->void:
	mutex.lock()
	pathToId.clear()
	textureArray.clear()
	mutex.unlock()

func getId(path:String)->int:
	mutex.lock()
	if(pathToId.has(path)):
		mutex.unlock()
		return pathToId[path]
	if(!FileAccess.file_exists(path)):
		mutex.unlock()
		return -1
	
	var newTexture:=load(path)
	
	if(newTexture == null || !newTexture is Texture2D):
		mutex.unlock()
		return -1
	
	var id = textureArray.size()
	pathToId[path] = id
	textureArray.append(newTexture)
	
	mutex.unlock()
	return id


func getTexture(id:int)->Texture2D:
	var rep:Texture2D = null
	mutex.lock()
	if(id < textureArray.size()):rep = textureArray[id]
	mutex.unlock()
	return rep
