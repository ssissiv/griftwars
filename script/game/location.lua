local Location = class( "Location", Entity )

function Location:init()
	Entity.init( self )
end

function Location:LocTable()
	return self
end

function Location:SetCoordinate( x, y, z )
	self.x = x
	self.y = y
	self.z = z
end

function Location:GetCoordinate()
	return self.x, self.y, self.z
end

function Location:SetImage( image )
	self.image = image
end

function Location:GetImage( image )
	return self.image
end

function Location:SetDetails( title, desc )
	self.title = title
	self.desc = desc
	self.contents = {}
end

function Location:AddAgent( agent )
	assert( is_instance( agent, Agent ))
	assert( table.arrayfind( self.contents, agent ) == nil )

	table.insert( self.contents, agent )
end

function Location:RemoveAgent( agent )
	assert( is_instance( agent, Agent ))

	local idx = table.arrayfind( self.contents, agent )
	table.remove( self.contents, idx )
end

function Location:Connect( other )
	assert( is_instance( other, Location ))
	other:GainAspect( Feature.Portal( self ))
	self:GainAspect( Feature.Portal( other ))
end


function Location:Contents()
	return ipairs( self.contents )
end

function Location:GetTitle()
	return self.title or "No Title"
end

function Location:GetDesc()
	return self.desc or "No Desc"
end

function Location:__tostring()
	return self:GetTitle()
end


