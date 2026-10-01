extends Node

var  _defHandler:=DefHandler.new()
var _textureHandler:=TextureHandler.new()
var _audioHandler:=AudioHandler.new()

var _ressourceHandlerArray:Array[RessourceHandler] = [
	_defHandler,_textureHandler,_audioHandler
]

func _ready() -> void:
	_defHandler.finishedLoading.connect(_defHandlerFinishedLoading)
	_textureHandler.finishedLoading.connect(_textureHandlerFinishedLoading)
	
	for r:RessourceHandler in _ressourceHandlerArray:
		r.init()
		r.putMessage.connect(_putMessage)
	
	WorldEvent.stateChanged.connect(_stateChanged)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			for r:RessourceHandler in _ressourceHandlerArray:r.clear()
			for r:RessourceHandler in _ressourceHandlerArray:r.startLoading()

#==============================================================================#
func _defHandlerFinishedLoading()->void:
	_textureHandler.putStopRequest()

func _textureHandlerFinishedLoading()->void:
	WorldEvent.setState(E_State.LOADING_RESSOURCE_FINISHED)
#==============================================================================#
func getDefCategories(script:GDScript)->Dictionary:
	return _defHandler.getDefCategories(script)

func atlasRequest(dest:ThingDef,prop:String,dict:Dictionary)->int:
	return _textureHandler.newAtlasRequest(dest,prop,dict)
func getAtlasFromId(id:int)->AtlasTexture:
	return _textureHandler.getAtlasFromId(id)
func spriteFrameRequest(dest:ThingDef,prop:String,dict:Dictionary)->int:
	return _textureHandler.newSpriteFrameRequest(dest,prop,dict)
func getSpriteFramesFromId(id:int)->SpriteFrames:
	return _textureHandler.getSpriteFramesFromId(id)

#==============================================================================#
#TEMPORAIRE, il faut un vrai systeme de message pour gérer ce merdier ><
#Normalement il devrais émètre vers une interface
func _putMessage(message:RessourceHandler.Message)->void:
	print(message)
func _putWarning(warning:RessourceHandler.Message)->void:
	print(warning)
func _putError(error:RessourceHandler.Message)->void:
	print(error)
#==============================================================================#
func _exit_tree() -> void:
	for r:RessourceHandler in _ressourceHandlerArray:r.exit()
