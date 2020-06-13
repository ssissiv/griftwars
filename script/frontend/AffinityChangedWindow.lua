local AffinityChangedWindow = class( "AffinityChangedWindow", NexusWindow )

function AffinityChangedWindow:init( affinity )
	assert( is_instance( affinity, Relationship.Affinity ))
	self.affinity = affinity
end


function AffinityChangedWindow:KeyPressed( key, screen )
	if key == "return" or key == "escape" then
		self.result = true
	end

	return false
end


function AffinityChangedWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	ui.SetNextWindowSize( 400, 150 )
	ui.SetNextWindowPos( (love.graphics.getWidth() - 400) / 2, (love.graphics.getHeight() - 150) / 2 )

    local shown, close, c = ui.Begin( "New Affinity!", false, flags )
    if shown then
    	local puppet = self.affinity.world:GetPuppet()
    	local other = self.affinity:GetOther( puppet )
    	local affinity = self.affinity:GetAffinity()

    	ui.Text( loc.format( "Your relationship with {1.Id} changed to {2}!", other:LocTable(), affinity ))
		if assets.AFFINITY_IMG[ affinity ] then
			ui.Image( assets.AFFINITY_IMG[ affinity ], 48, 48 )
		end

		if ui.Button( "Close" ) then
			self.result = true
		end
	end

    ui.End()

    if self.result then
		screen:RemoveWindow( self )
		self:Resume()
	end
end

function AffinityChangedWindow:Show()
	self.coro = coroutine.running()
	if self.coro then
		return coroutine.yield()
	end
end
