local ActionDie = class( "ActionDie" )

function ActionDie:init( name, faces )
	assert( self._classname == "ActionDie" )
	assert( type(faces) == "table" )
	self.name = name
	self.faces = faces
end

function ActionDie:SetOwner( owner )
	self.owner = owner
end

function ActionDie:GetWorld()
	local owner = self.owner
	while owner and not owner.world do
		owner = owner.owner
	end
	return owner and owner.world
end

function ActionDie.MakeHostileDie()
	return ActionDie( "Hostility",
	{	
		DIE_FACE.HOSTILITY, 1,
		DIE_FACE.HOSTILITY, 1,
		DIE_FACE.HOSTILITY, 1,
		DIE_FACE.HOSTILITY, 2,
		DIE_FACE.HOSTILITY, 2,
		DIE_FACE.NULL, 1,
	})
end


function ActionDie.MakeDiplomacyDie()
	return ActionDie( "Diplomacy",
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
	self.last_roll_time = self:GetWorld():GetDateTime()
	self:StartCooldown( 0.5 )
	return roll
end

function ActionDie:GetName()
	return self.name
end

function ActionDie:GetShortDesc()
	local txt = self.name .. (self.last_roll and "*" or "")
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
	if self.cooldown_ev then
		return self:GetWorld():GetEventTimeLeft( self.cooldown_ev )
	else
		return 0
	end
end

function ActionDie:StartCooldown( cooldown )
	self.cooldown_ev = self:GetWorld():ScheduleFunction( cooldown, self.StopCooldown, self )
end

function ActionDie:StopCooldown()
	self.cooldown_ev = nil
	self.last_roll = nil
end

function ActionDie:HasFace( face )
	assert( self.faces, tostr(self) )
	return table.contains( self.faces, face )
end

function ActionDie:IsSatisfiable( obj )
	for i, aspect in obj:Aspects() do
		if is_instance( aspect, Interaction ) then
			if aspect:IsSatisfiable( self ) then
				return true
			end
		end
	end
	return false
end

-- owner: Agent
function ActionDie:RenderObject( ui, viewer )
	ui.PushID( rawstring(self) )
	local focus = viewer:GetFocus()
	local disabled = (self.last_roll ~= nil) or focus == nil --or not self:IsSatisfiable( focus )
	if disabled then
		if self.last_roll then
			ui.PushStyleColor( "Button", 0.2, 0.5, 0.2, 1 )
			ui.PushStyleColor( "ButtonHovered", 0.2, 0.5, 0.2, 1 )
			ui.PushStyleColor( "ButtonActive", 0.2, 0.5, 0.2, 1 )
		else
			ui.PushStyleColor( "Button", 0.2, 0.2, 0.2, 1 )
			ui.PushStyleColor( "ButtonHovered", 0.2, 0.2, 0.2, 1 )
			ui.PushStyleColor( "ButtonActive", 0.2, 0.2, 0.2, 1 )
		end
	end

	local txt
	if self.last_roll then
		local pip, count = self:GetRoll()
		txt = loc.format( "{1} x{2}", pip, count )
	else
		txt = self:GetName()
	end

	if ui.Button( txt ) then
		if Input.IsControl() then
			DBG( self )
		elseif not disabled then
			self:Roll()
		end
	end
	-- if not self.last_roll then
	-- 	ui.SameLine( 0, 2 )
	-- 	if ui.Button( "*" ) then
	-- 		self:Roll()
	-- 	end
	-- end

	if disabled then
		ui.PopStyleColor()
		ui.PopStyleColor()
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

