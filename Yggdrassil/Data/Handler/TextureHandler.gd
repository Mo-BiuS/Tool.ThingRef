class_name TextureHandler extends RefCounted

var textureDict:Dictionary[String,Texture2D] = {}
var textureDictMutex:=Mutex.new()

var keyToId:Dictionary[String,int] = {}
var keyToIdMutex:=Mutex.new()

var atlasArray:Array[AtlasTexture] = []
var atlasMutex:=Mutex.new()

var spriteFramesArray:Array[SpriteFrames] = []
var spriteFramesMutex:=Mutex.new()

var _loadingThread:Thread
var keepLoading:bool
var workList:=DoubleLinkedList.new()
signal finishedLoading
#==============================================================================#
func startLoading()->void:
	keepLoading = true
	_loadingThread = Thread.new()
	_loadingThread.start(_loading)
func _loading()->void:
	while keepLoading || !workList.isEmpty():
		var request:TextureRequest = workList.popFront()
		if(request is AtlasRequest):_loadAtlas(request)
		if(request is SpriteFramesRequest):_loadSpriteFrames(request)
	call_deferred("_endLoading")
func _endLoading()->void:
	if _loadingThread != null and _loadingThread.is_started():
		_loadingThread.wait_to_finish()
	finishedLoading.emit()

#==============================================================================#
func _getTexture(path:String)->Texture2D:
	var rep:Texture2D = null
	textureDictMutex.lock()
	
	if(textureDict.has(path)):rep = textureDict[path]
	elif(FileAccess.file_exists(path)):
		textureDictMutex.unlock()
		var image:=Image.load_from_file(path)
		if(image != null && image is Image):
			rep = ImageTexture.create_from_image(image)
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
func newAtlasRequest(dest:ThingDef,prop:String,dict:Dictionary)->int:
	if(!(prop in dest)):return -1
	if(!DictFunc.dictAt(dict,"atlasData")):return -1
	if(!AtlasRequest.isValidData(dict["atlasData"])):return -1
	
	var request:=AtlasRequest.createRequest(dest,prop,dict["atlasData"])
	workList.pushBack(request)
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
func newSpriteFrameRequest(dest:ThingDef,prop:String,dict:Dictionary)->int:
	if(!(prop in dest)):return -1
	if(!DictFunc.dictAt(dict,"spriteFramesData")):return -1
	if(!SpriteFramesRequest.isValidData(dict["spriteFramesData"])):return -1
	
	var request:=SpriteFramesRequest.createRequest(dest,prop,dict["spriteFramesData"])
	workList.pushBack(request)
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
	
	workList.clear()
