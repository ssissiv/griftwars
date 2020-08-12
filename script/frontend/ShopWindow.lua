local ShopWindow = class( "ShopWindow", NexusWindow )

function ShopWindow:init( owner, buyer )
	assert( owner and buyer )
	self.owner = owner
	self.buyer = buyer
end

function ShopWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	ui.SetNextWindowSize( 500,300 )

	local txt = loc.format( "{1.Id}'s Shop", self.owner:LocTable())
    local visible, show = ui.Begin( txt, true, flags )
    if visible and show then
    	local shopkeep = self.owner:GetAspect( Job.ManageShop )
    	local money = self.buyer:GetInventory():GetMoney()

		ui.Columns( 2 )
		for i, obj in self.owner:GetInventory():Items() do
			local cost = shopkeep:GetBuyCost( obj, self.buyer )
			if cost < money then
				if ui.Selectable( tostring(obj), nil, "SpanAllColumns") then
					screen:RemoveWindow( self )
					self:Resume( obj )
				end
			else
				ui.TextColored( 0.5, 0.5, 0.5, 1, tostring(obj) )
			end
			ui.NextColumn()

			ui.TextColored( 1, 1, 0, 1, loc.format( "{1#money}", cost ))
			ui.NextColumn()
		end
		ui.Columns( 1 )
		ui.Separator()

		ui.Text( loc.format( "You have {1#money}.", money ))
		ui.Separator()
	end

	if not show or ui.Button( "Close" ) or self.close then
		screen:RemoveWindow( self )
		self:Resume()
	end

    ui.End()
end

function ShopWindow:ChooseBuyItem( world )
	world:TogglePause( PAUSE_TYPE.NEXUS )

	self.coro = coroutine.running()
	local obj = coroutine.yield()

	world:TogglePause( PAUSE_TYPE.NEXUS )

	return obj
end

function ShopWindow:KeyPressed( key, screen )
	if key == "return" or key == "escape" then
		self.close = true
		return true
	end

	return true
end



