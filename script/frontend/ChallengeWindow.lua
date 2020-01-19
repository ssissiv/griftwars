local ChallengeWindow = class( "ChallengeWindow" )

function ChallengeWindow:init( challenge )
	self.challenge = challenge
end

function ChallengeWindow:KeyPressed( key )
	self.challenge:Stop()
	return true
end

function ChallengeWindow:MousePressed( mx, my, btn )
	self.challenge:Stop()
	return true
end
function ChallengeWindow:RenderImGuiWindow( ui, screen )

	local ok, result = pcall( self.challenge.RenderImGuiWindow, self.challenge, ui, screen )
	if not ok then
		error( result )
	end

	if self.challenge:GetResult() then
		screen:RemoveWindow( self )
		coroutine.resume( self.coro, self.challenge:GetResult() )
	end
end

function ChallengeWindow:Show()
	self.coro = coroutine.running()
	return coroutine.yield()
end
