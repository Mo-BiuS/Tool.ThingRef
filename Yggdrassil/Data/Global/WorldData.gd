extends Node

var defHandler:=DefHandler.new()
var textureHandler:=TextureHandler.new()

func _ready() -> void:
	add_child(defHandler)
	add_child(textureHandler)
