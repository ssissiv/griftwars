local Lock = class( "Aspect.Lock", Aspect )

function Lock:Lock()
	self.locked = true
end

function Lock:Unlock()
	self.locked = false
end

function Lock:IsLocked()
	return self.locked
end
