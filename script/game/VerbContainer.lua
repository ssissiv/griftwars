local VERB_CLASSES = nil

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

	if not actor:IsSpawned() then
		return
	end

	-- Event registrants...
	actor:BroadcastEvent( AGENT_EVENT.COLLECT_VERBS, self, ... )

	-- Static VerbClasses...
	if VERB_CLASSES == nil then
		VERB_CLASSES = {}
		for id, class in pairs( CLASSES ) do
			if is_class( class, Verb ) and class.CollectVerbs then
				table.insert( VERB_CLASSES, class )
			end
		end
	end

	for i, class in ipairs( VERB_CLASSES ) do
		class.CollectVerbs( nil, self, actor, ... )
	end

	local location = actor:GetLocation()
	if location then
		self:CollectVerbsFromEntity( location, actor, ... )

		for i, obj in location:Contents() do
			self:CollectVerbsFromEntity( obj, actor, ... )
		end
	end
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

function VerbContainer:Verbs()
	return ipairs( self.verbs )
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