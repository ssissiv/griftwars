local Location = class( "Location" )

function Location:init()
end

function Location:OnSpawn( world )
	assert( self.world == nil )
	self.world = world
end

function Location:SetDetails( title, desc )
	self.title = title
	self.desc = desc
	self.contents = {}
	self.aspects = {}
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

function Location:GainAspect( aspect )
	table.insert( self.aspects, aspect )
	aspect:OnGainAspect( self )
end

function Location:LoseAspect( aspect )
	table.arrayremove( self.aspects, aspect )
	aspect:OnLoseAspect( self )
end

function Location:Aspects()
	return ipairs( self.aspects )
end

function Location:__tostring()
	return self:GetTitle()
end


