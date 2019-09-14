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
		DIE_FACE.HOSTILITY, 1,
		DIE_FACE.HOSTILITY, 1,
		DIE_FACE.HOSTILITY, 1,
		DIE_FACE.HOSTILITY, 2,
		DIE_FACE.HOSTILITY, 2,
		DIE_FACE.NULL, 1,
	})
end


function ActionDie.MakeDiplomacyDie( owner )
	return ActionDie( "Diplomacy", owner,
	{
		DIE_FACE.DIPLOMACY, 1,
		DIE_FACE.DIPLOMACY, 1,
		DIE_FACE.DIPLOMACY, 2,
		DIE_FACE.NULL, 1,
		DIE_FACE.NULL, 1,
		DIE_FACE.NULL, 1,
	})
end

function ActionDie:Roll()
	local n = math.floor( #self.faces / 2 )
	local roll = math.random( n )
	self.last_roll = roll
	self.last_roll_time = self.owner.world:GetDateTime()
	self:StartCooldown( 12 * ONE_HOUR )
	return roll
end

function ActionDie:GetName()
	return self.name
end

function ActionDie:GetShortDesc()
	local txt = self.name .. (self.last_roll and "*" or "")
	if self.owner:GetPlayer():HasCommitted( self ) then
		txt = "<"..txt..">"
	end
	return txt
end

function ActionDie:CanRoll()
	return self.last_roll == nil
end

function ActionDie:GetRollIndex()
	return self.last_roll
end

function ActionDie:GetRoll()
	if self.last_roll then
		return self.faces[ self.last_roll * 2 - 1 ], self.faces[ self.last_roll * 2 ]
	end
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
		ui.PushStyleColor( ui.Style_Button, 0.5, 1.0, 0.5, 1 )
	end

	local txt
	if self.last_roll then
		local pip, count = self:GetRoll()
		txt = loc.format( "{1} x{2}", pip, count )
	else
		txt = self:GetName()
	end
	if self.owner:GetPlayer():HasCommitted( self ) then
		txt = "["..txt.."]"
	end

	if ui.Button( txt ) then
		if self.owner:GetPlayer():HasCommitted( self ) then
			self.owner:GetPlayer():UncommitDice( self )
		else
			self.owner:GetPlayer():CommitDice( self )
		end
	end
	if not self.last_roll then
		ui.SameLine( 0, 2 )
		if ui.Button( "*" ) then
			self:Roll()
		end
	end

	if disabled then
		ui.PopStyleColor()
	end

	if ui.IsItemHovered() then
		ui.BeginTooltip()
		if self:IsCooldown() then
			ui.Text( loc.format( "Cooldown: {1#realtime}", self:GetCooldown() ))
		end

		if self:GetRoll() then
			ui.SameLine( 0, 10 )
			ui.TextColored( 0, 1, 0, 1, tostring( self:GetRoll() ))
		end
		ui.Text( table.concat( self.faces, "\n" ))

		ui.EndTooltip()
	end
	ui.PopID()
end

