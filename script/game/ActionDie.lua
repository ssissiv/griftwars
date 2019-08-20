local ActionDie = class( "ActionDie" )

function ActionDie:init( name, faces )
	self.name = name
	self.faces = faces
end

function ActionDie.MakeHostileDie()
	return ActionDie( "Hostility",
	{
		DIE_FACE.HOSTILITY,
		DIE_FACE.HOSTILITY,
		DIE_FACE.HOSTILITY,
		DIE_FACE.HOSTILITY_2X,
		DIE_FACE.HOSTILITY_2X,
		DIE_FACE.NULL,
	})
end


function ActionDie.MakeDiplomacyDie()
	return ActionDie( "Diplomacy",
	{
		DIE_FACE.DIPLOMACY,
		DIE_FACE.DIPLOMACY,
		DIE_FACE.DIPLOMACY_2X,
		DIE_FACE.NULL,
		DIE_FACE.NULL,
		DIE_FACE.NULL,
	})
end

function ActionDie:Roll()
	local roll = table.arraypick( self.faces )
	self.last_roll = roll
	return roll
end

function ActionDie:GetName()
	return self.name
end

function ActionDie:GetRoll()
	return self.last_roll
end

function ActionDie:ResetRoll()
	self.last_roll = nil
end

function ActionDie:HasFace( face )
	return table.contains( self.faces, face )
end
