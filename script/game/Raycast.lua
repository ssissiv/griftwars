
local Raycast = class( "Raycast" )

function Raycast.Generic( location, start_room, end_room, fn )
	local x0, y0 = start_room:GetCoordinate()
	local x1, y1 = end_room:GetCoordinate()
    local dx = math.abs( x1 - x0 )
   	local sx = x0 < x1 and 1 or -1
	local dy = -math.abs( y1 - y0 )
    local sy = y0 < y1 and 1 or -1
    local err = dx + dy
    while true do
		local tile = location:LookupTile( x0, y0 )
		if not tile then
			break
		end

		if not fn( tile ) then
			break
		end

		-- Disabling for now: makes it too easy to move out of the way, there's a DC check anyway.
		-- self:YieldForInterrupt( target, "incoming!" )
		-- self:YieldForTime( 0.5 * ONE_SECOND )

		if x0 == x1 and y0 == y1 then
			break
		end

        local e2 = 2*err
        if e2 >= dy then
            err = err + dy
            x0 = x0 + sx
		end
        if e2 <= dx then
        	err = err + dx
        	y0 = y0 + sy
        end
    end
end

function Raycast.Projectile( location, start_room, end_room, proj )
	local function AdvanceProjectile( tile )
		if not tile:IsPassable( proj ) then
			return false
		end

		proj:WarpToTile( tile )
		return true
	end

	Raycast.Generic( location, start_room, end_room, AdvanceProjectile )
end
