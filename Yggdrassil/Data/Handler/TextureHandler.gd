class_name TextureHandler extends Node

var textureDict:Dictionary[String,Texture2D] = {}
var textureDictMutex:=Mutex.new()

var pathToId:Dictionary[String,int] = {}
var pathToIdMutex:=Mutex.new()

var atlasArray:Array[AtlasTexture] = []
var atlasMutex:=Mutex.new()

#==============================================================================#
func _ready() -> void:
	WorldEvent.stateChanged.connect(_stateChanged)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			clear()

func clear()->void:
	pathToIdMutex.lock()
	pathToId.clear()
	pathToIdMutex.unlock()
	
	atlasMutex.lock()
	atlasArray.clear()
	atlasMutex.unlock()
	
	textureDictMutex.lock()
	textureDict.clear()
	textureDictMutex.unlock()

#==============================================================================#
func _getTexture(path:String)->Texture2D:
	var rep:Texture2D = null
	textureDictMutex.lock()
	
	if(textureDict.has(path)):rep = textureDict[path]
	elif(FileAccess.file_exists(path)):
		var loadedElement:=load(path)
		if(loadedElement != null && loadedElement is Texture2D):
			rep = loadedElement
			textureDict[path] = rep
	
	textureDictMutex.unlock()
	return rep

#==============================================================================#
func getAtlasId(path:String,rect:Rect2i)->int:
	var key := _getAtlasKey(path, rect)
	
	pathToIdMutex.lock()
	if(pathToId.has(key)):
		var id := pathToId[key]
		pathToIdMutex.unlock()
		return id
	else:
		var texture = _getTexture(path)
		if(texture == null):return -1
		
		var newAtlas:=AtlasTexture.new()
		newAtlas.region = rect
		newAtlas.atlas = texture
		
		atlasMutex.lock()
		var id := atlasArray.size()
		atlasArray.append(newAtlas)
		atlasMutex.unlock()
		
		pathToId[key] = id
		pathToIdMutex.unlock()
		
		return id
func getAtlas(id:int)->AtlasTexture:
	var rep:AtlasTexture = null
	atlasMutex.lock()
	if(id >= 0 && id < atlasArray.size()):rep = atlasArray[id]
	atlasMutex.unlock()
	return rep
func _getAtlasKey(texturePath, rect:Rect2i)->String:
	return texturePath + ":" + (
		str(rect.position.x) + "," +str(rect.position.y) + "," +
		str(rect.size.x) + "," +str(rect.size.y))
