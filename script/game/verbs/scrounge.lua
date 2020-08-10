local ScroungeTarget = class( "Aspect.ScroungeTarget", Aspect )

ScroungeTarget.event_handlers =
{
	[ CALC_EVENT.DC ] = function( self, verb, event_name, acc )
		if is_instance( verb, Verb.Scrounge ) and self.scrounge_count then
			acc:AddValue( self.scrounge_count * 2, "Already searched through" )
		end
	end,
}

function ScroungeTarget:SetLootTable( t )
	self.loot_table = t
end

function ScroungeTarget:CollectVerbs( verbs, actor, obj )
	local scrounge = true --actor:GetAspect( Verb.Scrounge )
	if scrounge and obj == self.owner then
		verbs:AddVerb( Verb.Scrounge( actor, self.owner ) )
	end
end

function ScroungeTarget:GenerateLoot( inventory )
	if self.loot_table then
		self.loot_table:SpawnLoot( inventory, self:GetWorld().rng )
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
Scrounge.act_desc = "Scrounge"

function Scrounge:init( actor, target )
	Verb.init( self, actor )
	self.target = target
end

function Scrounge:GetDesc( viewer )
	if self.target then
		return loc.format( "Scrounging {1.Id}", self.target:LocTable( viewer ))
	end
end

function Scrounge:FindTarget( actor )
	local targets = {}
	for i, obj in actor:GetLocation():Contents() do
		if obj:GetAspect( Aspect.ScroungeTarget ) then
			table.insert( targets, obj )
		end
	end
	return table.arraypick( targets )
end

function Scrounge:CanInteract()
	local actor, target = self.actor, self.target or self:FindTarget( self.actor )
	if not self:IsDoing() then
		if actor:IsBusy( self.FLAGS ) then
			return false, "Busy"
		end
	end

	if target == nil then
		return false, "No targets"
	end

	if not target:GetAspect( Aspect.ScroungeTarget ) then
		return false, "Can't scrounge " ..tostring(target)
	end

	if not actor:CanReach( target ) then
		return false, "Can't reach"
	end

	return self._base.CanInteract( self, actor )
end

function Scrounge:CalculateDC()
	return 10
end

function Scrounge:Interact()
	local actor, target = self.actor, self.target or self:FindTarget( actor )

	Msg:EchoAround( actor, "{1.Id} begins rummaging around in {2.Id}.", actor, target )
	Msg:EchoTo( actor, "You begin to rummage around in {1.Id}", target:LocTable( actor ) )

	-- while true do
		self:YieldForTime( 30 * ONE_MINUTE, "rate", 8.0 )
		actor:DeltaStat( STAT.FATIGUE, 5 )

		if self:IsCancelled() then
			return
		end

		local finder = self:GetRandomActor()
		local inv = target:GetAspect( Aspect.Inventory )

		-- Check to generate
		local ok, result_str = self:CheckDC( actor, target )
		if ok then
			target:GetAspect( Aspect.ScroungeTarget ):GenerateLoot( inv )
		end

		if not inv:IsEmpty() then
			if ok then
				Msg:EchoTo( finder, "You scrounge and find something... ({1})", result_str )
			else
				Msg:EchoTo( finder, "You don't find anything new. ({1})", result_str )
			end
			actor.world.nexus:LootInventory( actor, inv )
			Msg:EchoAround( finder, "{1.Id} scrounges about and finds something.", finder )
		else
			Msg:EchoTo( finder, "You fail to find anything of use. ({1})", result_str )
			Msg:EchoAround( finder, "{1.Id} mutters something unhappily.", finder )
		end

		actor:GainXP( 1 )

		
		finder:BroadcastEvent( AGENT_EVENT.SCROUNGE, actor )
		
	-- 	if math.random() < 0.5 then
	-- 		break
	-- 	end
	-- end
end
