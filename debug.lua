
-- print( "Nearest to", player:GetCoordinate() )
-- local x, y = player:GetCoordinate()
-- print( player.location:FindPassableTile( x, y, player ))

for i, v in pairs( world.entities ) do
	local p = v:GetAspect( Aspect.Portal )
	local t = v.GetTile and v:GetTile()
	if p and t and t:HasAspect( Aspect.Impass ) then
		print( i, v, p, t._classname )
	end
end