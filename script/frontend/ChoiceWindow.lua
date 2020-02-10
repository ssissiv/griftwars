local ChoiceWindow = class( "ChoiceWindow", NexusWindow )

function ChoiceWindow:init( title, body )
	self.title = title
	self.body = body
end


function ChoiceWindow:KeyPressed( key, screen )
	if key == "return" then
		self.result = true
		return true
	elseif key == "escape" then
		self.result = false
		return true
	end

	return false
end

function ChoiceWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }

	ui.SetNextWindowSize( 300, 200 )

    ui.Begin( self.title, false, flags )

    ui.TextWrapped( self.body )

    ui.NewLine()
    ui.Spacing()

    ui.SameLine( 60, 0 )
    if ui.Button( "Yes", 60, 30 ) then
    	self.result = true
    end
    ui.SameLine( 0, 60 )

    if ui.Button( "No", 60, 30 ) then
    	self.result = false
    end

 	ui.End()

 	if self.result ~= nil then
		screen:RemoveWindow( self )
		self:Resume( self.result )
	end
end

function ChoiceWindow:Show()
	self.coro = coroutine.running()
	return coroutine.yield()
end
