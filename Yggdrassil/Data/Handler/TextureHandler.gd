class_name TextureHandler extends RessourceHandler

var textureDict:Dictionary[String,Texture2D] = {}

var keyToId:Dictionary[String,int] = {}

var atlasArray:Array[AtlasTexture] = []

var spriteFramesArray:Array[SpriteFrames] = []

var _loadingSemaphore:Semaphore
var loadingQueue:=DoubleLinkedList.new()
var loadingMutex:=Mutex.new()

func init()->void:
	source = "TextureHandler"
#==============================================================================#
func startLoading()->void:
	loadingQueue.clear()
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
func putStopRequest()->void:
	loadingQueue.pushBack(StopRequest.new())
	_loadingSemaphore.post()

#==============================================================================#
func _getTexture(path:String)->Texture2D:
	loadingMutex.lock()
	if(textureDict.has(path)):
		var rep:= textureDict[path]
		loadingMutex.unlock()
		return rep
	loadingMutex.unlock()
	
	if(!FileAccess.file_exists(path)):
		_putError("File not found at %s" % path)
		return null
	
	var image:=Image.load_from_file(path)
	
	if(image == null):
		_putError("File couldn't be loaded %s" % path)
		return null
	else:
		var rep:= ImageTexture.create_from_image(image)
		loadingMutex.lock()
		textureDict[path] = rep
		loadingMutex.unlock()
		return rep

func _getIdFromKey(key:String)->int:
	loadingMutex.lock()
	if(keyToId.has(key)):
		var id := keyToId[key]
		loadingMutex.unlock()
		return id
	loadingMutex.unlock()
	return -1
#==============================================================================#
func newAtlasRequest(dest:Def,prop:String,dict:Dictionary)->int:
	if(!(prop in dest)):
		_putError("No propriety name %s in %s" % [prop,dest.key])
		return -1
	if(!DictFunc.dictAt(dict,"atlasData")):
		_putError("No atlasData detected for %s in %s" % [prop,dest.key])
		return -1
	if(!AtlasRequest.isValidData(dict["atlasData"])):
		_putError("AtlasData not valid for %s in %s" % [prop,dest.key])
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
		
		loadingMutex.lock()
		
		id = atlasArray.size()
		atlasArray.append(newAtlas)
		keyToId[request.key] = id
		
		loadingMutex.unlock()
	
	request.destination.set_deferred(request.property, id)
	return id
func getAtlasFromId(id:int)->AtlasTexture:
	var rep:AtlasTexture = null
	loadingMutex.lock()
	if(id >= 0 && id < atlasArray.size()):rep = atlasArray[id]
	loadingMutex.unlock()
	return rep

#==============================================================================#
func newSpriteFrameRequest(dest:Def,prop:String,dict:Dictionary)->int:
	if(!(prop in dest)):
		_putError("No propriety name %s in %s" % [prop,dest.key])
		return -1
	if(!DictFunc.dictAt(dict,"spriteFramesData")):
		_putError("No spriteFramesData detected for %s in %s" % [prop,dest.key])
		return -1
	if(!SpriteFramesRequest.isValidData(dict["spriteFramesData"])):
		_putError("spriteFramesData not valid for %s in %s" % [prop,dest.key])
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
		
		loadingMutex.lock()
		
		id = spriteFramesArray.size()
		spriteFramesArray.append(newSpriteFrames)
		keyToId[request.key] = id
		
		loadingMutex.unlock()
	request.destination.set_deferred(request.property, id)
	return id
func getSpriteFramesFromId(id:int)->SpriteFrames:
	var rep:SpriteFrames = null
	loadingMutex.lock()
	if(id >= 0 && id < spriteFramesArray.size()):rep = spriteFramesArray[id]
	loadingMutex.unlock()
	return rep
#==============================================================================#
func clear()->void:
	loadingMutex.lock()
	
	keyToId.clear()
	atlasArray.clear()
	textureDict.clear()
	spriteFramesArray.clear()
	loadingQueue.clear()
	
	loadingMutex.unlock()

func exit()->void:
	if _loadingThread != null && _loadingThread.is_started():
		_loadingThread.wait_to_finish()
