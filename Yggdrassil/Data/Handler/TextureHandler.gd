class_name TextureHandler extends RessourceHandler

var textureDict:Dictionary[String,Texture2D] = {}
var textureDictMutex:=Mutex.new()

var keyToId:Dictionary[String,int] = {}
var keyToIdMutex:=Mutex.new()

var atlasArray:Array[AtlasTexture] = []
var atlasMutex:=Mutex.new()

var spriteFramesArray:Array[SpriteFrames] = []
var spriteFramesMutex:=Mutex.new()

var _loadingSemaphore:Semaphore
var loadingQueue:=DoubleLinkedList.new()

func init()->void:
	source = "TextureHandler"
#==============================================================================#
func startLoading()->void:
	_loadingThread = Thread.new()
	_loadingSemaphore = Semaphore.new()
	_loadingThread.start(_loading)
func _loading()->void:
	while true:
		_loadingSemaphore.wait()
		var request:RessourceRequest = loadingQueue.popFront()
		if(request is StopRequest):break
		if(request is AtlasRequest):_loadAtlas(request)
		if(request is SpriteFramesRequest):_loadSpriteFrames(request)
	call_deferred("_endLoading")
func _endLoading()->void:
	if _loadingThread != null && _loadingThread.is_started():
		_loadingThread.wait_to_finish()
	finishedLoading.emit()

#==============================================================================#
func _getTexture(path:String)->Texture2D:
	if(textureDict.has(path)):
		textureDictMutex.lock()
		var rep:= textureDict[path]
		textureDictMutex.unlock()
		return rep
	
	if(!FileAccess.file_exists(path)):
		_putError("File not found at %s" % path)
		return null
	
	var image:=Image.load_from_file(path)
	
	if(image == null):
		_putError("File couldn't be loaded %s" % path)
		return null
	
	if(!image is Image):
		_putError("File isn't an image %s" % path)
		return null
	else:
		var rep:= ImageTexture.create_from_image(image)
		textureDictMutex.lock()
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
func newAtlasRequest(dest:Def,prop:String,dict:Dictionary)->int:
	if(!(prop in dest)):
		_putError("No propriety name %s in %s" % [prop,dest.name])
		return -1
	if(!DictFunc.dictAt(dict,"atlasData")):
		_putError("No atlasData detected for %s in %s" % [prop,dest.name])
		return -1
	if(!AtlasRequest.isValidData(dict["atlasData"])):
		_putError("AtlasData not valid for %s in %s" % [prop,dest.name])
		return -1
	
	var request:=AtlasRequest.createRequest(dest,prop,dict["atlasData"])
	loadingQueue.pushBack(request)
	_loadingSemaphore.post()
	return 0
func _loadAtlas(request:AtlasRequest)->int:
	var id:=_getIdFromKey(request.key)
	if(id == -1):
		var texture = _getTexture(request.texturePath)
		if(texture == null):
			return -1
		
		var newAtlas:=request.genAtlas(texture)
		
		atlasMutex.lock()
		id = atlasArray.size()
		atlasArray.append(newAtlas)
		atlasMutex.unlock()
		
		keyToIdMutex.lock()
		keyToId[request.key] = id
		keyToIdMutex.unlock()
	
	request.destination.set_deferred(request.property, id)
	return id
func getAtlasFromId(id:int)->AtlasTexture:
	var rep:AtlasTexture = null
	atlasMutex.lock()
	if(id >= 0 && id < atlasArray.size()):rep = atlasArray[id]
	atlasMutex.unlock()
	return rep

#==============================================================================#
func newSpriteFrameRequest(dest:Def,prop:String,dict:Dictionary)->int:
	if(!(prop in dest)):
		_putError("No propriety name %s in %s" % [prop,dest.name])
		return -1
	if(!DictFunc.dictAt(dict,"spriteFramesData")):
		_putError("No spriteFramesData detected for %s in %s" % [prop,dest.name])
		return -1
	if(!SpriteFramesRequest.isValidData(dict["spriteFramesData"])):
		_putError("spriteFramesData not valid for %s in %s" % [prop,dest.name])
		return -1
	
	var request:=SpriteFramesRequest.createRequest(dest,prop,dict["spriteFramesData"])
	loadingQueue.pushBack(request)
	_loadingSemaphore.post()
	return 0
func _loadSpriteFrames(request:SpriteFramesRequest)->int:
	var id:=_getIdFromKey(request.key)
	if(id == -1):
		var texture = _getTexture(request.texturePath)
		if(texture == null):
			return -1
		
		var newSpriteFrames := request.genSpriteFrames(texture)
		
		spriteFramesMutex.lock()
		id = spriteFramesArray.size()
		spriteFramesArray.append(newSpriteFrames)
		spriteFramesMutex.unlock()
		
		keyToIdMutex.lock()
		keyToId[request.key] = id
		keyToIdMutex.unlock()
	request.destination.set_deferred(request.property, id)
	return id
func getSpriteFramesFromId(id:int)->SpriteFrames:
	var rep:SpriteFrames = null
	spriteFramesMutex.lock()
	if(id >= 0 && id < spriteFramesArray.size()):rep = spriteFramesArray[id]
	spriteFramesMutex.unlock()
	return rep
#==============================================================================#
func putStopRequest()->void:
	loadingQueue.pushBack(StopRequest.new())
	_loadingSemaphore.post()
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
	
	loadingQueue.clear()
func exit()->void:
	if _loadingThread != null && _loadingThread.is_started():
		_loadingThread.wait_to_finish()
