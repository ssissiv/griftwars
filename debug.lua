
-- print( "Nearest to", player:GetCoordinate() )
-- local x, y = player:GetCoordinate()
-- print( player.location:FindPassableTile( x, y, player ))

for i, v in puppet:Relationships() do
	print( v )
	for k, vv in v:Agents() do
		if vv ~= puppet then
			print( "\t", k, vv, vv:GetLocation() )
			local x0, y0, z0 = vv:GetLocation():GetCoordinate()
			if z0 ~= 1 then
				vv:GetLocation():Flood( function( location, depth )
					local x, y, z = location:GetCoordinate()
					local continue = z == z0
					local stop = z == 1
					print( x, y, z )
					if stop then
						print( location, x, y, z, z0 )
					end
					return continue, stop
				end )
			end
		end
	end
end
