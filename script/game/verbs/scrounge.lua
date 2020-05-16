local ScroungeTarget = class( "Aspect.ScroungeTarget", Aspect )

function ScroungeTarget:SetLootTable( t )
	self.loot_table = t
end

function ScroungeTarget:CollectVerbs( verbs, actor, obj )
	local scrounge = true --actor:GetAspect( Verb.Scrounge )
	if scrounge and obj == self.owner then
		verbs:AddVerb( Verb.Scrounge( nil, self.owner ) )
	end
end

function ScroungeTarget:GenerateLoot( inventory )
	if self.loot_table then
		local fn = self.owner:GetAspect( Aspect.Rng ):WeightedPick( self.loot_table )
		local items = { fn() }
		for i, obj in ipairs( items ) do
			inventory:AddItem( obj )
		end
	end
	self.scrounge_count = (self.scrounge_count or 0) + 1
end


function ScroungeTarget:RenderDetailsUI( ui, screen )
	ui.Text( loc.format( "This {1} has been rummaged in {2} times.", self.owner, self.scrounge_count or 0))
end

-------------------------------------------------------------------------

AppendEnum( AGENT_EVENT, "SCROUNGE" )

local Scrounge = class( "Verb.Scrounge", Verb )

Scrounge.ACT_DESC =
{
	"You are scrounging for some useful things.",
	nil,
	"{1.Id} is here rummaging around.",
}

Scrounge.FLAGS = VERB_FLAGS.HANDS

function Scrounge:CalculateDC( mods )
	return 10
end

function Scrounge:GetDesc()
	return "Scrounge"
end

function Scrounge:RenderAgentDetails( ui, screen, viewer )
	if viewer:CanSee( self.owner ) then
		ui.Bullet()
		ui.Text( "Busy scrounging" )
	end
end


function Scrounge:GetShortDesc( viewer )
	if viewer == self.actor then
		return loc.format( self.ACT_DESC[1] )
	else
		return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ) )
	end
end

function Scrounge:FindTarget( actor )
	local targets = {}
	for i, obj in actor:GetLocation():Contents() do
		if self:CanInteract( actor, obj ) then
			table.insert( targets, obj )
		end
	end
	return table.arraypick( targets )
end

function Scrounge:CanInteract( actor, target )
	if not self:IsDoing() then
		if actor:IsBusy( self.FLAGS ) then
			return false, "Busy"
		end
	end

	if target == nil then
		target = self:FindTarget( actor )
	end

	if target == nil then
		return false, "No targets"

	elseif not target:GetAspect( Aspect.ScroungeTarget ) then
		return false, "Can't scrounge " ..tostring(target)

	elseif not actor:CanReach( target ) then
		return false, "Can't reach"
	end
	
	return self._base.CanInteract( self, actor )
end

function Scrounge:Interact( actor, target )
	if target == nil then
		target = self:FindTarget( actor )
	end

	Msg:ActToRoom( "{1.Id} begins rummaging around in {2.Id}.", actor, target )
	Msg:Echo( actor, "You begin to rummage around in {1.Id}", target:LocTable( actor ) )

	-- while true do
		self:YieldForTime( 30 * ONE_MINUTE, 8.0 )
		actor:DeltaStat( STAT.FATIGUE, 5 )

		if self:IsCancelled() then
			return
		end

		local finder = self:GetRandomActor()
		local inv = target:GetAspect( Aspect.Inventory )

		-- Check to generate
		if self:CheckDC() then
			target:GetAspect( Aspect.ScroungeTarget ):GenerateLoot( inv )
		end

		if not inv:IsEmpty() then
			actor.world.nexus:LootInventory( actor, inv )
			Msg:ActToRoom( "{1.Id} scrounges about and finds something.", finder )
		else
			Msg:Echo( finder, "You don't find anything useful." )
			Msg:ActToRoom( "{1.Id} mutters something unhappily.", finder )
		end

		actor:GainXP( 1 )

		finder:BroadcastEvent( AGENT_EVENT.SCROUNGE, actor )
		
	-- 	if math.random() < 0.5 then
	-- 		break
	-- 	end
	-- end
end
