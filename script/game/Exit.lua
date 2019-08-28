
local Exit = class( "Exit" )

function Exit:init()
end

function Exit:Connect( room1, room2 )
	self.room1, self.room2 = room1, room2
end

function Exit:GetDest( room )
	if room == self.room1 then
		return self.room2
	elseif room == self.room2 then
		return self.room1
	end
end

