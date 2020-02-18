
local Exit = class( "Exit" )

function Exit:Connect( room1, addr1, room2, addr2 )
	self.room1, self.room2 = room1, room2
	self.addr1, self.addr2 = addr1, addr2
end

function Exit:GetDest( room )
	if room == self.room1 then
		return self.room2, self.addr1
	elseif room == self.room2 then
		return self.room1, self.addr2
	end
end

