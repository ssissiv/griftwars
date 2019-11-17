local Calendar = class( "Calendar" )

function Calendar.FormatTime( datetime )
	if datetime == nil then
		return "nil"
	end
	
	local days =  math.floor( datetime / 24 )
	local hours = math.floor( datetime % 24 )
	local minutes = math.floor( (datetime - math.floor( datetime )) * 60 )
	local hour = hours % 12
	if hour == 0 then
		hour = 12
	end
	local am_pm = hours < 12 and "am" or "pm"
	return loc.format( "Day: {1} ({2}:{3%02d} {4})", days, hour, minutes, am_pm )
end


function Calendar.FormatWallTime( datetime )
	datetime = datetime / WALL_TO_GAME_TIME
	local hours = math.floor( datetime / (60 * 60) )
	local minutes = math.floor( datetime / 60 ) - (hours * 60)
	local seconds = math.floor( datetime % 60 )
	return loc.format( "{1}:{2%02d}:{3%02d}", hours, minutes, seconds )
end

function Calendar.FormatDuration( dt )
	local hours = math.floor( dt )
	local minutes = math.floor( (dt - hours) * 60 )
	if hours > 0 then
		return loc.format( "{1} hours, {2} mins", hours, minutes )
	else
		return loc.format( "{1} minutes", minutes )
	end
end

-- Integral hour of the specified datetime in the range [0, 23]
function Calendar.GetHour( datetime )
	local hours = math.floor( datetime % 24 )
	return hours
end


-- Return the floating point time in the current day in the range [0.0, 24.0)
function Calendar.GetTimeOfDay( datetime )
	local days = math.floor( datetime / 24 )
	return datetime - days * 24
end

-- Gets the duration from datetime to the next time the given hour of the day [0, 24) occurs.
function Calendar.GetTimeUntilHour( datetime, hour )
	local hour_now = datetime % 24
	if hour_now < hour then
		return hour - hour_now
	else
		return 24 - hour_now + hour
	end
end

-- Returns a normalized value [0..1] measuring how close datetime is to the target time of day.
-- Returns 1.0 if datetime represents a time of day identical to target_time, and 0 if it represents
-- the farther away it can be (12 hours difference).
function Calendar.GetNormalizedTimeOfDay( datetime, target_time )
	local n, modulus = math.modf(math.abs(Calendar.GetTimeOfDay( datetime ) - target_time) / HALF_DAY + 1.0, 1.0 )
	return modulus
end

