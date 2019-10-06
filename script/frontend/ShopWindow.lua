local ShopWindow = class( "ShopWindow" )

function ShopWindow:init( owner, buyer )
	assert( owner and buyer )
	self.owner = owner
	self.buyer = buyer
end

function ShopWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	ui.SetNextWindowSize( 500,300 )

	local txt = loc.format( "{1.Id}'s Shop", self.owner:LocTable())
    local shown, close, c = ui.Begin( txt, false, flags )
    if shown then
    	local shopkeep = self.owner:GetAspect( Aspect.Shopkeep )
		ui.Columns( 2 )
		for i, obj in self.owner:GetInventory():Items() do
			if ui.Selectable( tostring(obj), nil, "SpanAllColumns") then
				coroutine.resume( self.coro, obj )
			end
			ui.NextColumn()

			ui.TextColored( 1, 1, 0, 1, loc.format( "{1#money}", shopkeep:GetBuyCost( obj, self.buyer ) ))
			ui.NextColumn()
		end
		ui.Columns( 1 )
		ui.Separator()

		ui.Text( loc.format( "You have {1#money}.", self.buyer:GetInventory():GetMoney() ))
		ui.Separator()

		if ui.Button( "Close" ) then
			screen:RemoveWindow( self )
			coroutine.resume( self.coro, nil )
		end
	end

    ui.End()
end

function ShopWindow:ChooseBuyItem()
	self.coro = coroutine.running()
	return coroutine.yield()
end
