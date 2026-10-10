class_name TextureHandler extends RessourceHandler

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
		
		for cat:TerrainData in request.categoryList:
			cat.id = BetterTerrain.terrain_count(newTileSet)
			BetterTerrain.add_terrain(newTileSet,cat.key,cat.color,BetterTerrain.TerrainType.CATEGORY)
		
		for terrain:TerrainData in request.terrainList:
			terrain.id = BetterTerrain.terrain_count(newTileSet)
			var categoryIds:Array[int] = []
			for categoryKey: String in terrain.categories:
				for cat: TerrainData in request.categoryList:
					if cat.key == categoryKey:
						categoryIds.append(cat.id)
						break
			BetterTerrain.add_terrain(newTileSet,terrain.key,terrain.color,BetterTerrain.TerrainType.MATCH_TILES,categoryIds)
			for index:int in maskDict.keys():
				var bitImage:=maskDict[index]
				for x in int(bitImage.get_size().x/3):
					for y in int(bitImage.get_size().y/3):
						var pos:=Vector2i(x,y)*3+Vector2i.ONE
						var tileData:TileData = sourceDict[index].get_tile_data(Vector2i(x,y),0)
						if(tileData != null):
							if(bitImage.get_pixel(pos.x,pos.y).to_rgba32() == terrain.color.to_rgba32()):
								BetterTerrain.set_tile_terrain_type(newTileSet,tileData,terrain.id)
							if(bitImage.get_pixel(pos.x-1,pos.y).to_rgba32() == terrain.color.to_rgba32()):
								BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,terrain.id)
							if(bitImage.get_pixel(pos.x,pos.y+1).to_rgba32() == terrain.color.to_rgba32()):
								BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,terrain.id)
							if(bitImage.get_pixel(pos.x,pos.y-1).to_rgba32() == terrain.color.to_rgba32()):
								BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,terrain.id)
							if(bitImage.get_pixel(pos.x+1,pos.y).to_rgba32() == terrain.color.to_rgba32()):
								BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,terrain.id)
							
							if(bitImage.get_pixel(pos.x-1,pos.y-1).to_rgba32() == terrain.color.to_rgba32()):
								BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER,terrain.id)
							if(bitImage.get_pixel(pos.x+1,pos.y-1).to_rgba32() == terrain.color.to_rgba32()):
								BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER,terrain.id)
							if(bitImage.get_pixel(pos.x-1,pos.y+1).to_rgba32() == terrain.color.to_rgba32()):
								BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,terrain.id)
							if(bitImage.get_pixel(pos.x+1,pos.y+1).to_rgba32() == terrain.color.to_rgba32()):
								BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,terrain.id)
			
			for cat:TerrainData in request.categoryList:
				for index:int in maskDict.keys():
						var bitImage:=maskDict[index]
						for x in int(bitImage.get_size().x/3):
							for y in int(bitImage.get_size().y/3):
								var pos:=Vector2i(x,y)*3+Vector2i.ONE
								var tileData:TileData = sourceDict[index].get_tile_data(Vector2i(x,y),0)
								if(tileData != null):
									if(bitImage.get_pixel(pos.x,pos.y).to_rgba32() == cat.color.to_rgba32()):
										BetterTerrain.set_tile_terrain_type(newTileSet,tileData,cat.id)
								
									if(bitImage.get_pixel(pos.x-1,pos.y).to_rgba32() == cat.color.to_rgba32()):
										BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,cat.id)
									if(bitImage.get_pixel(pos.x,pos.y+1).to_rgba32() == cat.color.to_rgba32()):
										BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,cat.id)
									if(bitImage.get_pixel(pos.x,pos.y-1).to_rgba32() == cat.color.to_rgba32()):
										BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,cat.id)
									if(bitImage.get_pixel(pos.x+1,pos.y).to_rgba32() == cat.color.to_rgba32()):
										BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,cat.id)
									
									if(bitImage.get_pixel(pos.x-1,pos.y-1).to_rgba32() == cat.color.to_rgba32()):
										BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER,cat.id)
									if(bitImage.get_pixel(pos.x+1,pos.y-1).to_rgba32() == cat.color.to_rgba32()):
										BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER,cat.id)
									if(bitImage.get_pixel(pos.x-1,pos.y+1).to_rgba32() == cat.color.to_rgba32()):
										BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,cat.id)
									if(bitImage.get_pixel(pos.x+1,pos.y+1).to_rgba32() == cat.color.to_rgba32()):
										BetterTerrain.add_tile_peering_type(newTileSet,tileData,TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,cat.id)
		
		loadingMutex.lock()
		
		id = tileSetArray.size()
		tileSetArray.append(newTileSet)
		keyToId[request.key] = id
		
		loadingMutex.unlock()
	request.destination.set_deferred(request.property, id)
	return id
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
