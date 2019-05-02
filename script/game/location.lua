local Location = class( "Location", Entity )

function Location:init()
	Entity.init( self )
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


