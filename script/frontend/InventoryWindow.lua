local function GetObjectDesc( obj )
    local txt
    local wearable = obj:GetAspect( Aspect.Wearable )
    if wearable and wearable:IsEquipped() then
        local slot = wearable:GetEqSlot()
        txt = loc.format( "{1} <{2}>", obj:GetName(), EQ_SLOT_NAMES[ slot ] )
    else
        txt = obj:GetName()
    end
    return txt
end

------------------------------------------------------

local InventoryWindow = class( "InventoryWindow", NexusWindow )

function InventoryWindow:init( world, viewer, inventory )
	assert( inventory )
    self.world = world
	self.viewer = viewer
	self.inventory = inventory
end

function InventoryWindow:SetTitle( title )
    self.title = title
end

function InventoryWindow:Close( screen )
    screen:RemoveWindow( self )
    if self.coro then
        self:Resume()
    end
end

function InventoryWindow:LootAll()
    -- FIXME: need to loot all the objects.
    self.viewer:DoVerbAsync( Verb.LootAll( self.inventory ), self.inventory )
end

function InventoryWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
    ui.SetNextWindowSize( 400, 150 )
    ui.SetNextWindowPos( (love.graphics.getWidth() - 400) / 2, (love.graphics.getHeight() - 150) / 2 )

    local shown, close, c = ui.Begin( self.title or "Inventory", false, flags )
    if shown then
    	for i, obj in self.inventory:Items() do 
            local txt = GetObjectDesc( obj )

            if is_instance( obj.image, AtlasedImage ) then
                obj.image:RenderUI( ui )
                ui.SameLine( 0, 0 )
                ui.SetCursorPosY( ui.GetCursorPosY() + 16 )
            end

    		if ui.Selectable( txt, self.selected_obj == obj ) then
                if obj == self.selected_obj then
                    self.world.nexus:Inspect( self.viewer, obj )
                else
                    self:SelectObject( obj )
                end
            end
            if self.selected_obj == obj then
                screen:RenderPotentialVerbs( ui, self.viewer, "object", obj )
                self.shown_verbs = self.viewer:GetPotentialVerbs( "object", obj )
            end
    	end

        if self.coro then
            local done = self.inventory:IsEmpty()
            if done or ui.Button( "Close" ) then
                self:Close( screen )
            end
            ui.SameLine( 0, 10 )
            if ui.Button( "Loot All" ) then
                self:LootAll()
            end
        end
    end

    ui.End()
end

function InventoryWindow:SelectObject( obj )
    self.selected_obj = obj
    self.viewer:RegenVerbs( "object" )
end

function InventoryWindow:KeyPressed( key, screen )
    if key == "escape" then
        self:Close( screen )
        return true

    elseif key == "return" then
        self:LootAll()
        return true

    elseif key == "/" and Input.IsShift() then
        if self.selected_obj then
            self.world.nexus:Inspect( self.viewer, self.selected_obj )
            return true
        end

    elseif key == "tab" then
        local items = self.inventory:GetItems()
        local idx = table.arrayfind( items, self.selected_obj ) or 0
        self:SelectObject( items[ (idx % #items) + 1 ] )
        return true

    elseif key == "up" then
        local items = self.inventory:GetItems()
        local idx = table.arrayfind( items, self.selected_obj ) or 0
        self:SelectObject( items[ math.max( 1, idx - 1 ) ])
        return true

    elseif key == "down" then
        local items = self.inventory:GetItems()
        local idx = table.arrayfind( items, self.selected_obj ) or 0
        self:SelectObject( items[ math.min( #items, idx + 1 ) ])
        return true

    elseif key == "left" or key == "right" then
        return true

    elseif self.shown_verbs then
        local idx = tonumber(key)
        local verb = self.shown_verbs:VerbAt( idx )
        if verb then
            self.viewer:DoVerbAsync( verb, self.selected_obj )
            return true
        end
    end
end

function InventoryWindow:DoLoot()
    self.coro = coroutine.running()
    return coroutine.yield()
end
