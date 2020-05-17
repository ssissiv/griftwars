local Calendar = class( "Calendar" )

function Calendar.FormatTime( datetime, show_seconds )
	if datetime == nil then
		return "nil"
	end
	
	local days =  math.floor( datetime / 24 )
	local hours = math.floor( datetime % 24 )
	local fminutes = (datetime - math.floor( datetime )) * 60
	local minutes = math.floor( fminutes )
	local hour = hours % 12
	if hour == 0 then
		hour = 12
	end
	local am_pm = hours < 12 and "am" or "pm"
	if show_seconds then
		local minutes, seconds = math.modf( fminutes )
		seconds = math.floor( seconds * 60 )
		return loc.format( "Day: {1} ({2}:{3%02d} {4}, {5} seconds)", days, hour, minutes, am_pm, seconds )
	else
		return loc.format( "Day: {1} ({2}:{3%02d} {4})", days, hour, minutes, am_pm )
	end
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
	local seconds = (dt - hours - (minutes / 60)) * 3600
	if hours > 0 then
		return loc.format( "{1} hours, {2} mins", hours, minutes )
	elseif minutes > 0 then
		return loc.format( "{1} minutes", minutes )
	else
		return loc.format( "{1%.1f} seconds", seconds )
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
	local diff = math.abs( Calendar.GetTimeOfDay( datetime ) - (target_time % ONE_DAY) )
	if diff > HALF_DAY then
		return 1.0 - ((ONE_DAY - diff) / HALF_DAY)
	else
		return 1.0 - (diff / HALF_DAY)
	end
end

function Calendar.IsNight( datetime )
	local hour = Calendar.GetHour( datetime )
	return hour >= 20 or hour < 5
end

function Calendar.IsDay( datetime )
	return not Calendar.IsNight( datetime )
end

function Calendar.RenderDatetime( ui, datetime, world )
	local txt = Calendar.FormatTime( datetime )
	ui.Text( txt )
	if ui.IsItemHovered() and world then
		local now = world:GetDateTime()
		local tt
		if now > datetime then
			tt = loc.format( "{1} ago", Calendar.FormatDuration( now - datetime ))
		else
			tt = loc.format( "in {1}", Calendar.FormatDuration( datetime - now ))
		end
		ui.SetTooltip( loc.format( "{1} ({2})", now, tt ))
	end
end


