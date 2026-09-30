class_name ArrayFunc

static func vector2iAt(array:Array)->bool:
	return (array.size() == 2 && 
	(array[0] is int || array[0] is float) &&
	(array[1] is int || array[1] is float))
static func getVector2i(array:Array)->Vector2i:
	return Vector2i(array[0],array[1])

static func vector2iArrayAt(array:Array)->bool:
	for subArray in array:
		if(!(subArray is Array && vector2iAt(subArray))):return false
	return true
static func getVector2iArrayAt(array:Array)->Array[Vector2i]:
	var rep:Array[Vector2i] = []
	for subArray in array:
		rep.append(Vector2i(subArray[0],subArray[1]))
	return rep
