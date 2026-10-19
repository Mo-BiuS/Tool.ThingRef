class_name TextureHandler extends RessourceHandler

const PEERING_OFFSETS := {
	Vector2i(-1,  0): TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	Vector2i( 1,  0): TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
	Vector2i( 0, -1): TileSet.CELL_NEIGHBOR_TOP_SIDE,
	Vector2i( 0,  1): TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
	Vector2i(-1, -1): TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	Vector2i( 1, -1): TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	Vector2i(-1,  1): TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	Vector2i( 1,  1): TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
}

var textureDict:Dictionary[String,Texture2D] = {}

var keyToId:Dictionary[String,int] = {}

var atlasArray:Array[AtlasTexture] = []

var spriteFramesArray:Array[SpriteFrames] = []

var tileSetArray:Array[TileSet] = []

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
		elif(request is AtlasRequest):_loadAtlas(request)
		elif(request is SpriteFramesRequest):_loadSpriteFrames(request)
		elif(request is TileSetRequest):call_deferred("_loadTileSetRequest",request)
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
func newTileSetRequest(dest:Def,prop:String,dict:Dictionary)->int:
	if(!(prop in dest)):
		_putError("No propriety name %s in %s" % [prop,dest.key])
		return -1
	if(!DictFunc.dictAt(dict,"TileSetData")):
		_putError("No tileSetData detected for %s in %s" % [prop,dest.key])
		return -1
	if(!TileSetRequest.isValidData(dict["TileSetData"])):
		_putError("TileSetData not valid for %s in %s" % [prop,dest.key])
		return -1
	
	var request=TileSetRequest.createRequest(dest,prop,dict["TileSetData"])
	loadingQueue.pushBack(request)
	_loadingSemaphore.post()
	return 0
func _loadTileSetRequest(request:TileSetRequest)->int:
	var id:=_getIdFromKey(request.key)
	if(id == -1):
		var newTileSet:=TileSet.new()
		newTileSet.tile_size = request.size
		
		var maskDict:Dictionary[int,Image] = {}
		var sourceDict:Dictionary[int,TileSetAtlasSource] = {}
		for texturePath in request.textureDict.keys():
			var texture := _getTexture(texturePath)
			var mask := Image.load_from_file(request.textureDict[texturePath])
			if(texture != null && mask != null):
				var src := TileSetAtlasSource.new()
				src.texture = texture
				src.texture_region_size = request.size
				var sourceId:=newTileSet.add_source(src)
				maskDict[sourceId] = mask
				sourceDict[sourceId] = src
				for x in int(texture.get_size().x/request.size.x):
					for y in int(texture.get_size().y/request.size.y):
						src.create_tile(Vector2i(x,y))
		
		var categoryIdDict:Dictionary[String,int] = {}
		for cat:TerrainData in request.categoryList:
			cat.id = BetterTerrain.terrain_count(newTileSet)
			BetterTerrain.add_terrain(newTileSet,cat.key,cat.color,BetterTerrain.TerrainType.CATEGORY)
			categoryIdDict[cat.key] = cat.id
		
		for terrain:TerrainData in request.terrainList:
			terrain.id = BetterTerrain.terrain_count(newTileSet)
			var terrainCat:Array[int]
			for catName:String in terrain.categories:
				if(categoryIdDict.has(catName)):terrainCat.append(categoryIdDict[catName])
			BetterTerrain.add_terrain(newTileSet,terrain.key,terrain.color,BetterTerrain.TerrainType.MATCH_TILES,terrainCat)
			for index:int in maskDict.keys():
				_applyTileSetMask(newTileSet,terrain,maskDict[index],sourceDict[index])
		
		for cat:TerrainData in request.categoryList:
			for index:int in maskDict.keys():
				_applyTileSetMask(newTileSet,cat,maskDict[index],sourceDict[index])
		
		loadingMutex.lock()
		
		id = tileSetArray.size()
		tileSetArray.append(newTileSet)
		keyToId[request.key] = id
		
		loadingMutex.unlock()
	request.destination.set_deferred(request.property, id)
	return id
func _applyTileSetMask(newTileSet:TileSet,terrainData:TerrainData,bitImage:Image, tileSetSource:TileSetAtlasSource)->void:
	var targetColor := terrainData.color.to_rgba32()
	var gridSize:Vector2i = Vector2(bitImage.get_size()) / 3
	
	for x in gridSize.x:
		for y in gridSize.y:
			var tileData := tileSetSource.get_tile_data(Vector2i(x,y), 0)
			if tileData != null:
				var center := Vector2i(x,y)*3 + Vector2i.ONE
				
				if bitImage.get_pixelv(center).to_rgba32() == targetColor:
					BetterTerrain.set_tile_terrain_type(newTileSet, tileData, terrainData.id)
				for offset in PEERING_OFFSETS:
					if bitImage.get_pixelv(center + offset).to_rgba32() == targetColor:
						BetterTerrain.add_tile_peering_type(newTileSet, tileData, PEERING_OFFSETS[offset], terrainData.id)

func getTileSetFromId(id:int)->TileSet:
	var rep:TileSet = null
	loadingMutex.lock()
	if(id >= 0 && id < tileSetArray.size()):rep = tileSetArray[id]
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
