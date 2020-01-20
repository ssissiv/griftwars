local LootWindow = class( "LootWindow", NexusWindow )

function LootWindow:init( agent )
	assert( agent )
	self.agent = agent
	self.loot = {} -- Array of Items
	self.money = 0
end

function LootWindow:AddMoney( money )
	self.money = self.money + money
end

function LootWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	ui.SetNextWindowSize( 400, 150 )
	ui.SetNextWindowPos( (love.graphics.getWidth() - 400) / 2, (love.graphics.getHeight() - 150) / 2 )

    local shown, close, c = ui.Begin( "Loot!", false, flags )
    if shown then
    	ui.Text( "You find loot!" )
    	if self.money > 0 then
    		ui.Bullet()
    		if ui.Button( loc.format( "{1#money}", self.money )) then
    			self.agent:GetInventory():DeltaMoney( self.money )
    			self.money = 0
    		end
    	end

    	for i, item in ipairs( self.loot ) do
			-- TODO: item looting
    	end

    	local done = self.money == 0 and #self.loot == 0

		if done or ui.Button( "Close" ) then
			screen:RemoveWindow( self )
			self:Resume()
		end
	end

    ui.End()
end

function LootWindow:DoLoot()
	self.coro = coroutine.running()
	return coroutine.yield()
end
