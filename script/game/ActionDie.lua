local ActionDie = class( "ActionDie" )

function ActionDie:init( name, owner, faces )
	assert( self._classname == "ActionDie" )
	assert( is_instance( owner, Agent ) )
	assert( type(faces) == "table" )
	self.name = name
	self.owner = owner
	self.faces = faces
end

function ActionDie.MakeHostileDie( owner )
	return ActionDie( "Hostility", owner,
	{	
		DIE_FACE.HOSTILITY,
		DIE_FACE.HOSTILITY,
		DIE_FACE.HOSTILITY,
		DIE_FACE.HOSTILITY_2X,
		DIE_FACE.HOSTILITY_2X,
		DIE_FACE.NULL,
	})
end


function ActionDie.MakeDiplomacyDie( owner )
	return ActionDie( "Diplomacy", owner,
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
	self.last_roll_time = self.owner.world:GetDateTime()
	self:StartCooldown( 12 * ONE_HOUR )
	return roll
end

function ActionDie:GetName()
	return self.name
end

function ActionDie:CanRoll()
	return self.last_roll == nil
end

function ActionDie:GetRoll()
	return self.last_roll
end

function ActionDie:ResetRoll()
	self.last_roll = nil
end

function ActionDie:IsCooldown()
	return self.cooldown_ev ~= nil
end

function ActionDie:GetCooldown()
	return self.owner.world:GetEventTimeLeft( self.cooldown_ev )
end

function ActionDie:StartCooldown( cooldown )
	self.cooldown_ev = self.owner.world:ScheduleFunction( cooldown, self.StopCooldown, self )
end

function ActionDie:StopCooldown()
	self.cooldown_ev = nil
end

function ActionDie:HasFace( face )
	assert( self.faces, tostr(self) )
	return table.contains( self.faces, face )
end

-- owner: Agent
function ActionDie:RenderObject( ui, viewer )
	ui.PushID( rawstring(self) )
	local disabled = self.last_roll ~= nil
	if disabled then
		ui.PushStyleColor( ui.Style_Button, 0.2, 0.2, 0.2, 1 )
	end

	if ui.Button( self:GetName() ) and not self.last_roll then
		self:Roll()
	end

	if disabled then
		ui.PopStyleColor()
	end

	if self:IsCooldown() then
		ui.Text( loc.format( "Cooldown: {1#realtime}", self:GetCooldown() ))
	end

	if self:GetRoll() then
		ui.SameLine( 0, 10 )
		ui.TextColored( 0, 1, 0, 1, tostring( self:GetRoll() ))
	end
	if ui.IsItemHovered() then
		ui.SetTooltip( table.concat( self.faces, "\n" ))
	end
	ui.PopID()
end

