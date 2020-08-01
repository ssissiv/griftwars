local SleepWindow = class( "SleepWindow" )

function SleepWindow:init( agent )
	assert( agent )
	self.agent = agent
	self.stat_xp = {}
	self.xp = self.agent:GetStatValue( STAT.XP )
	self.xp_used = 0
end

function SleepWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	ui.SetNextWindowSize( 500,300 )

	local txt = loc.format( "Sleeping in {1#location}", self.agent:GetLocation() )
    local visible, show = ui.Begin( txt, true, flags )
    if visible and show then
    	if self.xp then
	    	ui.Text( loc.format( "XP: {1}", self.xp - self.xp_used ))
	    	ui.Spacing()
		
		    for stat, aspect in self.agent:Stats() do
		    	local xp_rate = aspect:GetGrowthRate()
		    	if xp_rate then
		    		local current_points = self.stat_xp[ stat ] or 0
					local new_value, new_growth, percent = aspect:CalculateValueWithXP( current_points )
		    		local txt = loc.format( "{1} ({2#percent})", tostring(stat), percent )
		    		local changed, points = ui.SliderInt( txt, current_points, 0, current_points + (self.xp - self.xp_used) )
		    		if changed then
			    		self.xp_used = self.xp_used + (points - current_points)
			    		self.stat_xp[ stat ] = points
			    	end
			    	ui.SameLine( 0, 10 )
			    	ui.Text( loc.format( "{1} =>", aspect:GetValue() ))
			    	ui.SameLine( 0, 10 )
			    	ui.TextColored( 0, 1, 0, 1, tostring( new_value ))
		    	end
		    end

		    ui.Separator()
		end

		if ui.Button( self.xp_used > 0 and "Assign XP" or "Close" ) then
			screen:RemoveWindow( self )
			coroutine.resume( self.coro, self.stat_xp )
		end

	elseif not show then
		screen:RemoveWindow( self )
		coroutine.resume( self.coro, self.stat_xp )		
	end

    ui.End()
end

function SleepWindow:DoSleep()
	self.coro = coroutine.running()
	return coroutine.yield()
end
