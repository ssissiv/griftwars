local VerbContainer = class( "VerbContainer" )

function VerbContainer:init( id )
	self.id = id
	self.verbs = {}
	self.dirty = true
end

function VerbContainer:CollectVerbs( actor, obj )
	if not self.dirty then
		return
	end

	table.clear( self.verbs )
	
	self.dirty = false
	self.actor = actor

	if not actor:IsSpawned() then
		return
	end

	local location = actor:GetLocation()
	if obj == nil then
		-- This means accumulate verbs for all potential targets.
		if location then
			for i, v in location:Contents() do
				self:CollectVerbsFromEntity( actor, actor, v )

				if v ~= actor then
					self:CollectVerbsFromEntity( v, actor, v )
				end
			end
		else
			self:CollectVerbsFromEntity( actor, actor, actor )
		end

	else
		-- The actor itself or its Aspects can add verbs.
		self:CollectVerbsFromEntity( actor, actor, obj )

		-- The target itself or its Aspects can add verbs.
		if obj and obj ~= actor then
			self:CollectVerbsFromEntity( obj, actor, obj )
		end
	end

	-- The location in which the actor resides or its Aspects can add verbs.
	if location then
		self:CollectVerbsFromEntity( location, actor, obj )
	end

	-- Event registrants...
	actor:BroadcastEvent( AGENT_EVENT.COLLECT_VERBS, self, obj )
end

function VerbContainer:CollectVerbsFromEntity( entity, actor, obj )
	if entity.CollectVerbs then
		entity:CollectVerbs( self, actor, obj )
	end

	-- Aspects get a say.
	for i, aspect in entity:Aspects() do
		if aspect.CollectVerbs then
			aspect:CollectVerbs( self, actor, obj)
		end
	end
end

function VerbContainer:SetDirty()
	self.dirty = true
end

function VerbContainer:AddVerb( v )
	table.insert( self.verbs, v )
	v.actor = self.actor
end

function VerbContainer:VerbAt( idx )
	return self.verbs[ idx ]
end

function VerbContainer:FindVerb( verb )
	return table.arrayfind( self.verbs, verb )
end

function VerbContainer:FindVerbClass( verb_class )
	for i, verb in ipairs( self.verbs ) do
		if is_instance( verb, verb_class ) then
			return verb
		end
	end
end

function VerbContainer:Verbs()
	return ipairs( self.verbs )
end

function VerbContainer:CountVerbs()
	return #self.verbs
end

function VerbContainer:CancelVerbs()
	for i = #self.verbs, 1, -1 do
		self.verbs[i]:Cancel()
		table.remove( self.verbs, i )
	end
end

function VerbContainer:SortByDistanceTo( x, y )
	local function fn( v1, v2 )
		local tx1, ty1
		if v1:GetTarget() then
			tx1, ty1 = AccessCoordinate( v1:GetTarget() )
		end
		local dist1 = distance( tx1 or x, ty1 or y, x, y )
		local tx2, ty2
		if v2:GetTarget() then
			tx2, ty2 = AccessCoordinate( v2:GetTarget() )
		end
		local dist2 = distance( tx2 or x, ty2 or y, x, y )
		return dist1 < dist2
	end

	table.sort( self.verbs, fn )
end
