local VerbContainer = class( "VerbContainer" )

function VerbContainer:init()
	self.verbs = {}
end

function VerbContainer:AddVerb( v )
	table.insert( self.verbs, v )
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