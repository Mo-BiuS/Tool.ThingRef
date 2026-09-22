extends Node

var refHandler:=RefHandler.new()
var textureHandler:=TextureHandler.new()

func _ready() -> void:
	add_child(refHandler)
	add_child(textureHandler)
