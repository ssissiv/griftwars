----------------------------------------------------------------
-- Localization macros

return
{
	-- List things:
	-- "foo"
	-- "foo and bar"
	-- "foo, bar, and foobar"
	test = function( t )
		return tostring(t)
	end,

	listing = function( t )
		local concat = t[1]
		for i = 2, #t - 1 do
			concat = concat .. ", " ..t[i]
		end
		if #t >= 3 then
			concat = concat .. ", and " .. t[#t]
		elseif #t >= 2 then
			concat = concat .. " and " .. t[#t]
		end
		return concat
	end,

	a_an = function( s )
		local c = s:sub( 1, 1 ):upper()
		if c == "a" or c == "e" or c == "i" or c == "o" or c == "u" then
			return string.format( "an %s", s )
		else
			return string.format( "a %s", s )
		end
	end,

	-- Percentage, 0 places of precision.
	percent = function( num )
		local percent = num * 100
		if percent < 0 then
			return string.format( "-%.0f%%", -percent )
		else
			return string.format( "%.0f%%", percent )
		end
	end,

	-- Signed percent, 0 places of precision.
	spercent = function( num )
		num = num or 0
		if type(num) ~= "number" then
			num = 999
		end
		local percent = math.floor( num * 100 )
		if percent > 0 then
			return "+%"..tostring(percent)
		elseif percent < 0 then
			return "-%"..tostring(math.abs(percent))
		else
			return "%"..tostring(percent)
		end
	end,

	money = function( num )
		return loc.format( "{1} {1*coin|coins}", num )
	end,

	location = function( location )
		if location.GetTitle then
			return location:GetTitle()
		end
	end,

	realtime = function( datetime )
		return Calendar.FormatWallTime( datetime )
	end,
}

