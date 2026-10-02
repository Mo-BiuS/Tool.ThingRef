class_name AudioHandler extends RessourceHandler

var keyToId:Dictionary[String,int] = {}
var keyToIdMutex:=Mutex.new()

var audioArray:Array[AudioStream] = []
var audioMutex:=Mutex.new()

var _loadingSemaphore:Semaphore
var loadingQueue:=DoubleLinkedList.new()

func init()->void:
	source = "AudioHandler"
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
		if(request is AudioRequest):_loadAudio(request)
	call_deferred("_endLoading")
func _endLoading()->void:
	if _loadingThread != null && _loadingThread.is_started():
		_loadingThread.wait_to_finish()
	finishedLoading.emit()
func putStopRequest()->void:
	loadingQueue.pushBack(StopRequest.new())
	_loadingSemaphore.post()
#==============================================================================#
func newAudioRequest(dest:Def,prop:String,dict:Dictionary)->int:
	if(!(prop in dest)):
		_putError("No propriety name %s in %s" % [prop,dest.key])
		return -1
	if(!DictFunc.dictAt(dict,"audioData")):
		_putError("No audioData detected for %s in %s" % [prop,dest.key])
		return -1
	if(!AudioRequest.isValidData(dict["audioData"])):
		_putError("AudioData not valid for %s in %s" % [prop,dest.key])
		return -1
	
	var request:=AudioRequest.createRequest(dest,prop,dict["audioData"])
	loadingQueue.pushBack(request)
	_loadingSemaphore.post()
	return 0
func _loadAudio(request:AudioRequest)->int:
	keyToIdMutex.lock()
	if(keyToId.has(request.key)):
		var rep:=keyToId[request.key]
		keyToIdMutex.unlock()
		return rep
	keyToIdMutex.unlock()
	
	var stream:AudioStream
	if(request.audioPath.ends_with(".mp3")):
		stream = AudioStreamMP3.load_from_file(request.audioPath)
	elif(request.audioPath.ends_with(".ogg")):
		stream = AudioStreamOggVorbis.load_from_file(request.audioPath)
	
	
	keyToIdMutex.lock()
	audioMutex.lock()
	var id := audioArray.size()
	audioArray.append(stream)
	keyToId[request.key] = id
	keyToIdMutex.unlock()
	audioMutex.unlock()
	
	return id

func getAudioFromId(id:int)->AudioStream:
	var rep:AudioStream = null
	audioMutex.lock()
	if(id >= 0 && id < audioArray.size()):rep = audioArray[id]
	audioMutex.unlock()
	return rep
#==============================================================================#
func clear()->void:
	keyToId.clear()
func exit()->void:
	if _loadingThread != null and _loadingThread.is_started():
		_loadingThread.wait_to_finish()
