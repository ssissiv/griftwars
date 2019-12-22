local History = class( "Aspect.History", Aspect )

local MAX_SIZE = 1000

function History:init()
	self.items = {}
	self.tail, self.head = nil, nil
	self.count = 0
end

function History:Log( fmt, ... )
	local item = { fmt, ... }

	if self.tail then
		self.tail.next = item
	end

	self.tail = item
	if self.head == nil then
		self.head = item
	end
	self.count = self.count + 1

	while self.count > MAX_SIZE do
		self.head = self.head.next
		self.count = self.count - 1
	end
end

local function IterFn( state, i )
	if i == nil then
		state.iter = state.head
	elseif state.iter then
		state.iter = state.iter.next
	end

	if state.iter then
		return (i or 0) + 1, state.iter
	end
end

function History:Items()
	return IterFn, { head = self.head, iter = nil }
end
