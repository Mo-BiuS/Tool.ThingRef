extends Node

var _defHandler:=DefHandler.new()
var _textureHandler:=TextureHandler.new()
var _audioHandler:=AudioHandler.new()

func _ready() -> void:
	_defHandler.finishedLoading.connect(_defHandlerFinishedLoading)
	_textureHandler.finishedLoading.connect(_textureHandlerFinishedLoading)
	WorldEvent.stateChanged.connect(_stateChanged)

func _stateChanged(_old:E_State.Value,new:E_State.Value)->void:
	match new:
		E_State.LOADING_RESSOURCE_START:
			_defHandler.clear()
			_textureHandler.clear()
			_audioHandler.clear()
			
			_textureHandler.startLoading()
			_defHandler.startLoading()

#==============================================================================#
func _defHandlerFinishedLoading()->void:
	_textureHandler.keepLoading = false

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
