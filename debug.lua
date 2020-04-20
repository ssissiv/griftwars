
-- print( "Nearest to", player:GetCoordinate() )
-- local x, y = player:GetCoordinate()
-- print( player.location:FindPassableTile( x, y, player ))

for i, ent in pairs( world.entities ) do
	if ent.GetCoordinate and ent.GetTile then
		local x, y = ent:GetCoordinate()
		local tile = ent:GetTile()
		local tx, ty
		if tile then
			tx, ty = tile:GetCoordinate()
		end

		if x ~= tx and y ~= ty then
			print( x, y, tile, ent, ent.world, ent.location, tile, ent.location.map )
		end
	end
end
