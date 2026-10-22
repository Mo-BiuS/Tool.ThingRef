extends Node

var _defHandler:=DefHandler.new()
var _textureHandler:=TextureHandler.new()
var _audioHandler:=AudioHandler.new()

var _resourceHandlerArray:Array[ResourceHandler] = [
	_textureHandler,_audioHandler,_defHandler
]
var _nHandlerFinished:int

signal finishedLoading()
signal putMessage(message:ResourceHandler.Message)

var loadingTime:float

func _ready() -> void:
	_defHandler.finishedLoading.connect(_defHandlerFinishedLoading)
	
	for r:ResourceHandler in _resourceHandlerArray:
		r.init()
		r.putMessage.connect(_putMessage)
		r.finishedLoading.connect(_handlerFinishedLoading)

func startLoading()->void:
	interrupt()
	clear()
	
	_nHandlerFinished = 0
	loadingTime = Time.get_ticks_msec()
	for r:ResourceHandler in _resourceHandlerArray:r.startLoading()

func appendDef(script:GDScript)->void:
	_defHandler.defLoadOrder.append(script)

func clear()->void:
	for r:ResourceHandler in _resourceHandlerArray:r.clear()

func interrupt()->void:
	for r:ResourceHandler in _resourceHandlerArray:r.interrupt()
#==============================================================================#
func _defHandlerFinishedLoading()->void:
	_textureHandler.putStopRequest()
	_audioHandler.putStopRequest()

func _handlerFinishedLoading()->void:
	_nHandlerFinished += 1
	if(_nHandlerFinished >= _resourceHandlerArray.size()):
		loadingTime = float(Time.get_ticks_msec()-loadingTime)/1000
		finishedLoading.emit()
#==============================================================================#
func getDefCategories(script:GDScript)->Dictionary:
	return _defHandler.getDefCategories(script)

func atlasRequest(dest:Def,prop:String,dict:Dictionary)->int:
	return _textureHandler.newAtlasRequest(dest,prop,dict)
func getAtlasFromId(id:int)->AtlasTexture:
	return _textureHandler.getAtlasFromId(id)
func spriteFrameRequest(dest:Def,prop:String,dict:Dictionary)->int:
	return _textureHandler.newSpriteFrameRequest(dest,prop,dict)
func getSpriteFramesFromId(id:int)->SpriteFrames:
	return _textureHandler.getSpriteFramesFromId(id)
func tileSetRequest(dest:Def,prop:String,dict:Dictionary)->int:
	return _textureHandler.newTileSetRequest(dest,prop,dict)
func getTileSetFromId(id:int)->TileSet:
	return _textureHandler.getTileSetFromId(id)

func audioRequest(dest:Def,prop:String,dict:Dictionary)->int:
	return _audioHandler.newAudioRequest(dest,prop,dict)
func getAudioFromId(id:int)->AudioStream:
	return _audioHandler.getAudioFromId(id)
#==============================================================================#
#TEMPORAIRE, il faut un vrai systeme de message pour gérer ce merdier ><
#Normalement il devrais émètre vers une interface
func _putMessage(message:ResourceHandler.Message)->void:
	putMessage.emit(message)
#==============================================================================#
func _exit_tree() -> void:
	interrupt()
