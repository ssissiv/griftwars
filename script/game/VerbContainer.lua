local VerbContainer = class( "VerbContainer" )

function VerbContainer:init( id )
	self.id = id
	self.verbs = {}
	self.dirty = true
end

function VerbContainer:CollectVerbs( actor, ... )
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
	if location then
		self:CollectVerbsFromEntity( location, actor, ... )

		for i, obj in location:Contents() do
			self:CollectVerbsFromEntity( obj, actor, ... )
		end
	end

	-- Event registrants...
	actor:BroadcastEvent( AGENT_EVENT.COLLECT_VERBS, self, ... )
end

function VerbContainer:CollectVerbsFromEntity( entity, actor, ... )
	if entity.CollectVerbs then
		entity:CollectVerbs( self, actor, ... )
	end

	-- Verbs get a say.
	for i, aspect in entity:Aspects() do
		if aspect.CollectVerbs then
			aspect:CollectVerbs( self, actor, ... )
		end
	end
end

function VerbContainer:SetDirty()
	self.dirty = true
end

function VerbContainer:AddVerb( v )
	table.insert( self.verbs, v )
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

function VerbContainer:PickRandom()
	return table.arraypick( self.verbs )
end