local Calendar = class( "Calendar" )

function Calendar.FormatTime( datetime )
	local days =  math.floor( datetime / 24 )
	local hours = math.floor( datetime % 24 )
	local hour = hours % 12
	if hour == 0 then
		hour = 12
	end
	local am_pm = hours < 12 and "am" or "pm"
	return loc.format( "Day: {1} ({2} {3})", days, hour, am_pm )
end
