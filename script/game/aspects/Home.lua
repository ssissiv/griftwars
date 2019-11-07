local Home = class( "Feature.Home", Feature )

function Home:init( home_owner )
	Feature.init( self )
	self.home_owner = home_owner
end

function Home:GetHomeOwner()
	return self.home_owner
end

