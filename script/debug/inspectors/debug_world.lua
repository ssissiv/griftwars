--------------------------------------------------------------------
-- A debug root level node.

local DebugWorld = class( "DebugWorld", DebugTable )
DebugWorld.REGISTERED_CLASS = World

function DebugWorld:init( world )
	DebugTable.init( self, world )
    self.world = world
end

function DebugWorld:RenderPanel( ui, panel, dbg )
    if ui.Button( "+One Hour" ) then
        self.world:AdvanceTime( ONE_HOUR )
    end

    if ui.TreeNode( "History" ) then
        local changed, filter = ui.InputText( "Filter", self.history_filter or "", 512 )
        if filter and filter ~= self.history_filter then
            self.history_filter = filter
        end
        local filter_obj = DBQ( self.history_filter )
        if filter_obj ~= nil then
            ui.TextColored( 0, 1, 1, 1, "Filtering on: " .. tostring(filter_obj))
        end
        ui.Indent( 10 )
        for i, v in self.world:GetAspect( Aspect.History ):Items() do
            if filter_obj == nil or table.contains( v, filter_obj ) then
                local txt = loc.format( table.unpack( v, 1, table.maxn( v ) ))
                if ui.Selectable( txt ) then
                    DBG(v)
                end
            end
        end
        ui.Unindent( 10 )
        ui.TreePop()
    end

    if ui.TreeNode( "Scheduled Events" ) then
        ui.Text( string.format( "%d events", #self.world.scheduled_events ))
        
    	for i, ev in ipairs( self.world.scheduled_events ) do
    		local txt = string.format( "%.3f - %s", ev.when - self.world.datetime, tostring(ev[1]))
            if ev.when <= self.world.datetime then
                ui.TextColored( 255, 255, 0, 255, txt )
            else
        		ui.Text( txt )
            end
    		for i = 1, #ev do
    			ui.Text( "  "..tostring(ev[i]))    			
    		end
    	end
    	ui.TreePop()
    end
   	ui.Separator()

    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 