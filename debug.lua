
-- print( "Nearest to", player:GetCoordinate() )
-- local x, y = player:GetCoordinate()
-- print( player.location:FindPassableTile( x, y, player ))

for i, ent in pairs( world.entities ) do
	if is_instance( ent, Agent ) and ent:HasAspect( Aspect.FactionMember ) then
		print( ent )
	end
end
