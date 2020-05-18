local Portal = class( "Object.Portal", Object )
Portal.name = "Portal"

function Portal:init( worldgen_tag )
	assert( worldgen_tag )
	self.portal = self:GainAspect( Aspect.Portal() )
	self.portal:SetWorldGenTag( worldgen_tag )
end

function Portal:SetDetails( image, name )
	self.image = image
	self.name = name
end

function Portal:GetShortDesc( viewer )
	return self.name
end

function Portal:GetDest()
	return self.portal:GetDest()
end

function Portal:GetMapChar()
	if self.portal:GetDest() then
		return "^"
	else
		return "^", constants.colours.BLACK
	end
end

function Portal:GetName()
	if self.portal == nil or self.portal:GetDest() == nil then
		return loc.format( "{1} to nowhere!", self.name )
	else
		return loc.format( "{1} to {2}", self.name, self.portal:GetDest() )
	end
end

-------------------------------------------------------------

local CaveEntrance = class( "Portal.CaveEntrance", Portal )

CaveEntrance.image = assets.TILE_IMG.CAVE_ENTRANCE
CaveEntrance.name = "Cave Entrance"


-------------------------------------------------------------

local AbandonedWell = class( "Portal.AbandonedWell", Portal )

AbandonedWell.image = assets.TILE_IMG.ABANDONED_WELL
AbandonedWell.name = "Abandoned well"

function AbandonedWell:init()
	Portal.init( self, "bottom_of_well entry" )
	self.portal.one_way = true	
end


function AbandonedWell:OnSpawn( world )
	Portal.OnSpawn( self, world )
	self.reqs = self:GainAspect( Aspect.Requirements() )
	self.reqs:AddReq( Req.Stat( STAT.CLIMBING, 10 ))
end
