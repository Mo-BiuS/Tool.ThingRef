@abstract class_name RessourceHandler extends RefCounted

@warning_ignore("unused_signal") signal putMessage(m:Message)
@warning_ignore("unused_signal") signal finishedLoading

@warning_ignore("unused_private_class_variable")
var _loadingThread:Thread
@warning_ignore("unused_private_class_variable")
var source:String

@abstract func init()->void
@abstract func startLoading()->void
@abstract func clear()->void
@abstract func exit()->void

func _putMessage(message:String)->void:
	var m:=Message.new()
	m.source = source
	m.gravity = MessageGravity.MESSAGE
	m.message = message
	putMessage.emit(m)
func _putWarning(message:String)->void:
	var m:=Message.new()
	m.source = source
	m.gravity = MessageGravity.WARNING
	m.message = message
	putMessage.emit(m)
func _putError(message:String)->void:
	var m:=Message.new()
	m.source = source
	m.gravity = MessageGravity.ERROR
	m.message = message
	putMessage.emit(m)
	
class Message:
	var source:String
	var gravity:MessageGravity
	var message:String
	
	func _to_string() -> String:
		return "%s -> %s" % [source,message]

enum MessageGravity{
	MESSAGE=0,
	WARNING=1,
	ERROR=2
}
