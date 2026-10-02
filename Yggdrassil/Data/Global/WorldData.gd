extends Node

var  _defHandler:=DefHandler.new()
var _textureHandler:=TextureHandler.new()
var _audioHandler:=AudioHandler.new()

var _ressourceHandlerArray:Array[RessourceHandler] = [
	_defHandler,_textureHandler,_audioHandler
]
var _nHandlerFinished:int

func _ready() -> void:
	_defHandler.finishedLoading.connect(_defHandlerFinishedLoading)
	
	for r:RessourceHandler in _ressourceHandlerArray:
		r.init()
		r.putMessage.connect(_putMessage)
		r.finishedLoading.connect(_handlerFinishedLoading)
	
	WorldEvent.stateChanged.connect(_stateChanged)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			_nHandlerFinished = 0
			for r:RessourceHandler in _ressourceHandlerArray:r.clear()
			for r:RessourceHandler in _ressourceHandlerArray:r.startLoading()

#==============================================================================#
func _defHandlerFinishedLoading()->void:
	_textureHandler.putStopRequest()
	_audioHandler.putStopRequest()

func _handlerFinishedLoading()->void:
	_nHandlerFinished += 1
	if(_nHandlerFinished >= _ressourceHandlerArray.size()):
		WorldEvent.setState(E_State.LOADING_RESSOURCE_FINISHED)
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

func audioRequest(dest:Def,prop:String,dict:Dictionary)->int:
	return _audioHandler.newAudioRequest(dest,prop,dict)
func getAudioFromId(id:int)->AudioStream:
	return _audioHandler.getAudioFromId(id)
#==============================================================================#
#TEMPORAIRE, il faut un vrai systeme de message pour gérer ce merdier ><
#Normalement il devrais émètre vers une interface
func _putMessage(message:RessourceHandler.Message)->void:
	print(message)
#==============================================================================#
func _exit_tree() -> void:
	for r:RessourceHandler in _ressourceHandlerArray:r.exit()
