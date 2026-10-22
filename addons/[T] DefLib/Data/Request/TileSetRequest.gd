class_name TileSetRequest extends ResourceRequest

var size:Vector2i
var categoryList:Array[LoadingTerrainStruct]
var terrainList:Array[LoadingTerrainStruct]
var textureDict:Dictionary[String,String]

static func isValidData(dict:Dictionary)->bool:
	if(!DictFunc.positiveVector2iAt(dict,"TileSize")):return false
	
	var allCategoryDict := DictFunc.getDictAt(dict,"Category")
	for catKey:String in allCategoryDict.keys():
		var categoryDict := DictFunc.getDictAt(allCategoryDict,catKey)
		if !DictFunc.colorAt(categoryDict,"MaskValue"):return false
	
	var allTerrainDict := DictFunc.getDictAt(dict,"TerrainData")
	for catKey:String in allTerrainDict.keys():
		var terrainDict := DictFunc.getDictAt(allTerrainDict,catKey)
		if !DictFunc.colorAt(terrainDict,"MaskValue"):return false
		if DictFunc.arrayAt(terrainDict,"Category"):
			if(!DictFunc.stringArrayAt(terrainDict,"Category")):return false
	
	if(!DictFunc.arrayAt(dict,"Textures")):return false
	for subDict:Dictionary in DictFunc.getArrayAt(dict,"Textures"):
		if(!subDict is Dictionary):return false
		if(!(subDict.has("TileMapPath") && subDict.has("MaskPath"))):return false
		if(!(DictFunc.fileAt(subDict,"TileMapPath") && DictFunc.fileAt(subDict,"MaskPath"))):return false
	
	return true

static func createRequest(dest:Def,prop:String,dict:Dictionary)->TileSetRequest:
	var rep:=TileSetRequest.new()
	rep.destination = dest
	rep.property = prop
	rep.key = dest.key
	
	rep.size = DictFunc.getVector2iAt(dict,"TileSize")
	
	rep.categoryList = []
	var allCategoryDict := DictFunc.getDictAt(dict,"Category")
	for catKey:String in allCategoryDict.keys():
		var categoryDict := DictFunc.getDictAt(allCategoryDict,catKey)
		var terrainData:=LoadingTerrainStruct.new()
		terrainData.key = catKey
		terrainData.color = DictFunc.getColorAt(categoryDict,"MaskValue")
		rep.categoryList.append(terrainData)
	
	rep.terrainList = []
	var allTerrainDict := DictFunc.getDictAt(dict,"TerrainData")
	for catKey:String in allTerrainDict.keys():
		var terrainDict := DictFunc.getDictAt(allTerrainDict,catKey)
		var terrainData:=LoadingTerrainStruct.new()
		terrainData.key = catKey
		terrainData.color = DictFunc.getColorAt(terrainDict,"MaskValue")
		terrainData.categories = DictFunc.getStringArrayAt(terrainDict,"Category")
		rep.terrainList.append(terrainData)
	
	rep.textureDict = {}
	var textureArray:=DictFunc.getArrayAt(dict,"Textures")
	for tDict:Dictionary in textureArray:
		rep.textureDict[tDict["TileMapPath"]] = tDict["MaskPath"]
	
	return rep
func _genKey()->void:
	pass
