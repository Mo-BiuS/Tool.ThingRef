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
		var image:=Image.load_from_file(path)
		if(image != null && image is Image):
			rep = ImageTexture.create_from_image(image)
			textureDict[path] = rep
	
	textureDictMutex.unlock()
	return rep
func _getIdFromKey(key:String)->int:
	keyToIdMutex.lock()
	if(keyToId.has(key)):
		var id := keyToId[key]
		keyToIdMutex.unlock()
		return id
	keyToIdMutex.unlock()
	return -1
#==============================================================================#
func getAtlasIdFromDict(dict:Dictionary)->int:
	if(!DictFunc.dictAt(dict,"atlasData")):return -1
	if(!AtlasLoadData.isValidData(dict["atlasData"])):return -1
	
	return _getAtlasId(AtlasLoadData.loadDataFrom(dict["atlasData"]))
func _getAtlasId(data:AtlasLoadData)->int:
	var id:=_getIdFromKey(data.key)
	if(id == -1):
		var texture = _getTexture(data.texturePath)
		if(texture == null):
			return -1
		
		var newAtlas:=data.genAtlas(texture)
		
		atlasMutex.lock()
		id = atlasArray.size()
		atlasArray.append(newAtlas)
		atlasMutex.unlock()
		
		keyToIdMutex.lock()
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
func getSpriteFramesIdFromDict(dict:Dictionary)->int:
	if(!DictFunc.dictAt(dict,"spriteFramesData")):return -1
	if(!SpriteFramesLoadData.isValidData(dict["spriteFramesData"])):return -1
	return _getSpriteFramesId(SpriteFramesLoadData.loadDataFrom(dict["spriteFramesData"]))
func _getSpriteFramesId(data:SpriteFramesLoadData)->int:
	var id:=_getIdFromKey(data.key)
	if(id == -1):
		var texture = _getTexture(data.texturePath)
		if(texture == null):
			return -1
		
		var newSpriteFrames := data.genSpriteFrames(texture)
		
		spriteFramesMutex.lock()
		id = spriteFramesArray.size()
		spriteFramesArray.append(newSpriteFrames)
		spriteFramesMutex.unlock()
		
		keyToIdMutex.lock()
		keyToId[data.key] = id
		keyToIdMutex.unlock()
	return id
func getSpriteFrames(id:int)->SpriteFrames:
	var rep:SpriteFrames = null
	spriteFramesMutex.lock()
	if(id >= 0 && id < spriteFramesArray.size()):rep = spriteFramesArray[id]
	spriteFramesMutex.unlock()
	return rep
