class_name AudioHandler extends RessourceHandler

func init()->void:
	source = "AudioHandler"
func startLoading()->void:
	finishedLoading.emit()
func clear()->void:
	pass
func exit()->void:
	if _loadingThread != null and _loadingThread.is_started():
		_loadingThread.wait_to_finish()
