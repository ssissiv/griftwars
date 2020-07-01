local History = class( "Aspect.History", Aspect )

local MAX_SIZE = 1000

function History:init()
	self:ResetHistory()
end

function History:ResetHistory()
	self.items = {}
	self.tail, self.head = nil, nil
	self.count = 0
end

function History:SaveToFile( filename )
	-- OSX: /Users/user/Library/Application Support/LOVE/griftwars/
	local file, err = love.filesystem.newFile( filename, "w" )
	if not file then
		print( "SaveToFile failed", filename, err )
		return
	end

	self.file = file
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

	if self.file then
        local txt = loc.format( fmt, ... )
        self.file:write( txt )
        self.file:write( "\n" )
        self.file:flush()
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

function History:PostLoad()
	self:ResetHistory()
end

function History:__serialize()	
	return
	{
		_classname = self._classname,
	}
end

