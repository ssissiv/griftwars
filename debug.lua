
print( "Nearest to", player:GetCoordinate() )
local x, y = player:GetCoordinate()
print( player.location:FindPassableTile( x, y, player ))
