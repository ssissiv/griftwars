-------------------------------------

local GrabNearbyBoulders = class( "Verb.GrabNearbyBoulders", Verb.Plan )

function GrabNearbyBoulders:GetDesc( viewer )
	return "Grabbing nearby boulders"
end

function GrabNearbyBoulders:FindNearbyBoulder( actor )
	-- ARE there are any nearby boulders?
	local boulders
	for i, obj in actor:GetLocation():Contents() do
		if is_instance( obj, Object.Boulder ) then
			if boulders == nil then
				boulders = {}
			end
			table.insert( boulders, obj )
		end
	end

	local x0, y0 = actor:GetCoordinate()
	table.sort( boulders, function( e1, e2 ) return distance( x0, y0, e1:GetCoordinate() ) < distance( x0, y0, e2:GetCoordinate() ) end )
	return boulders[1]
end

function GrabNearbyBoulders:CalculateUtility( actor )
	if not actor:InCombat() then
		return 0
	end

	-- Do I not have a boulder?
	local obj = actor:GetHeldObject()
	if is_instance( obj, Object.Boulder ) then
		return 1
	end

	if not self:FindNearbyBoulder( actor ) then
		return 2
	end

	return actor:GetAspect( Verb.HostileCombat ):CalculateUtility( actor ) + 1
end

function GrabNearbyBoulders:Interact( actor )
	local boulder = self:FindNearbyBoulder( actor )
	local travel = Verb.Travel( boulder )
	if self:DoChildVerb( travel ) then
		local loot = Verb.LootObject()
		if self:DoChildVerb( loot, boulder ) then
			local equip = Verb.HoldObject():SetTarget( boulder )
			self:DoChildVerb( equip )
		end
	end
end
