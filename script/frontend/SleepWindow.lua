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
    local shown, close, c = ui.Begin( txt, false, flags )
    if shown then
    	if self.xp then
	    	ui.Text( loc.format( "XP: {1}", self.xp - self.xp_used ))
	    	ui.Spacing()
		
		    for stat, aspect in self.agent:Stats() do
		    	local xp_rate = aspect:GetGrowthRate()
		    	if xp_rate then
		    		local current_points = self.stat_xp[ stat ] or 0
		    		local txt = loc.format( "{1} ({2#percent})", tostring(stat), xp_rate * current_points + aspect:GetGrowth() )
		    		local changed, points = ui.SliderInt( txt, current_points, 0, current_points + (self.xp - self.xp_used) )
		    		if changed then
			    		self.xp_used = self.xp_used + (points - current_points)
			    		self.stat_xp[ stat ] = points
			    	end
		    	end
		    end

		    ui.Separator()
		end

		if ui.Button( self.xp_used > 0 and "Assign XP" or "Close" ) then
			screen:RemoveWindow( self )
			coroutine.resume( self.coro, self.stat_xp )
		end
	end

    ui.End()
end

function SleepWindow:DoSleep()
	self.coro = coroutine.running()
	return coroutine.yield()
end
