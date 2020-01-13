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
		for i, obj in location:Contents() do
			if is_instance( obj, Agent ) then
				self:CollectVerbsFromAgent( obj, actor, ... )
			end 
		end
	end
end

function VerbContainer:CollectVerbsFromAgent( agent, actor, ... )
	-- Verbs get a say.
	for i, verb in agent:Verbs() do
		if verb.CollectVerbs then
			verb:CollectVerbs( self, actor, ... )
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

function VerbContainer:ClearVerbs()
	table.clear( self.verbs )
end

function VerbContainer:PickRandom()
	return table.arraypick( self.verbs )
end