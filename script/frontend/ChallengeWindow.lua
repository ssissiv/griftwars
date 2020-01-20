local ChallengeWindow = class( "ChallengeWindow" )

function ChallengeWindow:init( challenge )
	self.challenge = challenge
end

function ChallengeWindow:KeyPressed( key )
	if self.challenge:IsStarted() then
		self.challenge:Stop()
	else
		if key == "return" then
			self.challenge:Start()
		else
			self.challenge:Cancel()
		end
	end
	return true
end

function ChallengeWindow:MousePressed( mx, my, btn )
	if self.challenge:IsStarted() then
		self.challenge:Stop()
	end
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
