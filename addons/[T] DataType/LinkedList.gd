class_name DoubleLinkedList extends RefCounted

var size:=0
var head:DoubleLinkedListNode = null
var mutex:=Mutex.new()

class DoubleLinkedListNode extends RefCounted:
	var value:Variant = null
	var nextItem:DoubleLinkedListNode = null
	var previousItem:DoubleLinkedListNode = null

#==================================================================================================#
func pushFront(v:Variant,lockMutex:bool = true)->void:
	if(lockMutex):mutex.lock()
	match size:
		0:
			head = DoubleLinkedListNode.new()
			head.value = v
		1:
			var n = DoubleLinkedListNode.new()
			n.value = head.value
			n.previousItem = head
			n.nextItem = head
			
			head.value = v
			head.nextItem = n
			head.previousItem = n
		_:
			var n = DoubleLinkedListNode.new()
			n.value = head.value
			n.previousItem = head
			n.nextItem = head.nextItem
			
			head.nextItem.previousItem = n
			
			head.value = v
			head.nextItem = n
	size+=1
	if(lockMutex):mutex.unlock()
func pushBack(v:Variant,lockMutex:bool = true)->void:
	if(lockMutex):mutex.lock()
	match size:
		0:
			head = DoubleLinkedListNode.new()
			head.value = v
		1:
			var n = DoubleLinkedListNode.new()
			n.value = v
			n.previousItem = head
			n.nextItem = head
			
			head.nextItem = n
			head.previousItem = n
		_:
			var n = DoubleLinkedListNode.new()
			n.value = v
			n.previousItem = head.previousItem
			n.nextItem = head
			
			head.previousItem.nextItem = n
			head.previousItem = n
	size+=1
	if(lockMutex):mutex.unlock()

#==================================================================================================#
func popFront(lockMutex:bool = true)->Variant:
	if(lockMutex):mutex.lock()
	var rep
	match size :
		0:
			rep =  null
		1:
			rep = head.value
			head.value = null
			head = null
			size = 0
		2:
			rep = head.value
			head.value = head.nextItem.value
			
			var old := head.nextItem
			
			head.nextItem = null
			head.previousItem = null
			
			old.value = null
			old.nextItem = null
			old.previousItem = null
			
			size = 1
		_:
			rep = head.value
			
			var old := head.nextItem
			head.value = head.nextItem.value
			head.nextItem.nextItem.previousItem = head
			head.nextItem = head.nextItem.nextItem
			
			old.value = null
			old.nextItem = null
			old.previousItem = null
			
			size-=1
	if(lockMutex):mutex.unlock()
	return rep
func popBack(lockMutex:bool = true)->Variant:
	if(lockMutex):mutex.lock()
	var rep
	match size:
		0:
			rep = null
		1:
			size = 0
			rep = head.value
			head.value = null
			head = null
		2:
			rep = head.previousItem.value
		
			var old := head.previousItem
			
			head.nextItem = null
			head.previousItem = null
			
			old.value = null
			old.nextItem = null
			old.previousItem = null
			
			size = 1
		_:
			rep = head.previousItem.value
			
			var old := head.previousItem
			head.previousItem.previousItem.nextItem = head
			head.previousItem = head.previousItem.previousItem
			
			old.value = null
			old.nextItem = null
			old.previousItem = null
			
			size-=1
	if(lockMutex):mutex.unlock()
	return rep

#==================================================================================================#
## USE THIS BEFORE DELETING, It's a double chained list!!! 
## memory loss is expected if you don't clear the list before
func clear()->void:
	mutex.lock()
	while(size > 0):popBack(false)
	mutex.unlock()
func getSize()->int:
	mutex.lock()
	var rep = size
	mutex.unlock()
	return rep
func isEmpty()->bool:
	mutex.lock()
	var rep := size == 0
	mutex.unlock()
	return rep

#==================================================================================================#
func _to_string() -> String:
	var rep
	mutex.lock()
	match size:
		0: rep = "[]"
		1: rep = "[" + str(head.value) + "]"
		_:
			rep = "[ "+str(head.value)
			var i:DoubleLinkedListNode = head.nextItem
			while i != head:
				rep+=", "+str(i.value)
				i = i.nextItem
			rep+=" ]"
	mutex.unlock()
	return rep
