class_name TextureHandler extends Node

var textureDict:Dictionary[String,Texture2D] = {}
var textureDictMutex:=Mutex.new()

var keyToId:Dictionary[String,int] = {}
var keyToIdMutex:=Mutex.new()

var atlasArray:Array[AtlasTexture] = []
var atlasMutex:=Mutex.new()

var spriteFramesArray:Array[SpriteFrames] = []
var spriteFramesMutex:=Mutex.new()

#==============================================================================#
func _ready() -> void:
	WorldEvent.stateChanged.connect(_stateChanged)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			clear()

func clear()->void:
	keyToIdMutex.lock()
	keyToId.clear()
	keyToIdMutex.unlock()
	
	atlasMutex.lock()
	atlasArray.clear()
	atlasMutex.unlock()
	
	textureDictMutex.lock()
	textureDict.clear()
	textureDictMutex.unlock()
	
	spriteFramesMutex.lock()
	spriteFramesArray.clear()
	spriteFramesMutex.unlock()

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
func _getKeyFromId(key:String)->int:
	keyToIdMutex.lock()
	if(keyToId.has(key)):
		var id := keyToId[key]
		keyToIdMutex.unlock()
		return id
	keyToIdMutex.unlock()
	return -1
#==============================================================================#
func getAtlasId(data:AtlasLoadData)->int:
	var id:=_getKeyFromId(data.key)
	if(id == -1):
		var texture = _getTexture(data.texturePath)
		if(texture == null):
			keyToIdMutex.unlock()
			return -1
		
		var newAtlas:=AtlasTexture.new()
		newAtlas.region = data.rect
		newAtlas.atlas = texture
		
		atlasMutex.lock()
		id = atlasArray.size()
		atlasArray.append(newAtlas)
		atlasMutex.unlock()
		
		keyToId[data.key] = id
		keyToIdMutex.unlock()
	
	return id
func getAtlas(id:int)->AtlasTexture:
	var rep:AtlasTexture = null
	atlasMutex.lock()
	if(id >= 0 && id < atlasArray.size()):rep = atlasArray[id]
	atlasMutex.unlock()
	return rep

#==============================================================================#
func getSpriteFramesId(data:SpriteFramesLoadData)->int:
	var id:=_getKeyFromId(data.key)
	if(id == -1):
		pass
	return -1
