local EventSystem = class("EventSystem")

function EventSystem:init()
    self.listeners = {}
    self.tmp_listeners = {}
    self.depth = 0
end

function EventSystem:ListenForEvent(event, listener, fn, priority)
    assert(event)
    assert(type(fn or listener.OnGlobalEvent) == "function", "Listener missing handler function")
    if self.listeners_by_event == nil then
        self.listeners_by_event = {}
    end
    if self.listeners_by_event[event] == nil then
    	self.listeners_by_event[event] = {}
    end
    self:AddListenerToList( listener, fn, priority, self.listeners_by_event[ event ])
end

function EventSystem:ListenForAny(listener, fn, priority)
    assert( self.listeners[ listener ] == nil )
    assert(type(fn or listener.OnGlobalEvent) == "function", "Listener missing handler function")
    self:AddListenerToList( listener, fn, priority, self.listeners )
end

function EventSystem:ListenForEvents(listener, ...)
    for i = 1, select( "#", ... ) do
        self:ListenForEvent( select( i, ... ), listener )
    end
end

function EventSystem:StopListening(event, listener)
	if event then
	    local listeners = self.listeners_by_event[event]
        self:RemoveListenerFromList( listener, listeners )
    else
        if self.listeners_by_event then
    		for k,v in pairs(self.listeners_by_event) do
                self:RemoveListenerFromList( listener, v )
    	    end
        end
        self:RemoveListenerFromList( listener, self.listeners )
   end

	for depth = 1, self.depth do
        self:RemoveListenerFromList( listener, self.tmp_listeners[ depth ] )
	end
end

function EventSystem:HasListeners()
    if self.listeners_by_event then
        for event, v in pairs(self.listeners_by_event) do
            if next(v) ~= nil then
                return true
            end
        end
    end
    return next(self.listeners) ~= nil
end

function EventSystem:IsListener( listener, event )
    if event == nil then
        return self.listeners[ listener ] ~= nil
    elseif self.listeners_by_event and self.listeners_by_event[ event ] then
        return table.contains( self.listeners_by_event[ event ], listener )
    end

    return false
end


function EventSystem:RemoveListenerFromList(listener, t)
    for i = 1, #t, 3 do
        if t[i] == listener then
            table.remove( t, i )
            table.remove( t, i )
            table.remove( t, i )
            break
        end
    end
    assert( table.arrayfind( t, listener ) == nil )
end

function EventSystem:AddListenerToList(listener, fn, priority, t)
    if table.arrayfind( t, listener ) then
        return
    end

    priority = priority or -math.huge
    fn = fn or true

    for i = 1, #t, 3 do
        local l, p = t[i], t[i+2]
        if priority < p then
            table.insert( t, i, listener )
            table.insert( t, i + 1, fn )
            table.insert( t, i + 2, priority )
            return
        end
    end

    table.insert( t, listener )
    table.insert( t, fn )
    table.insert( t, priority )
end

function EventSystem:RemoveListener(listener)
	self:StopListening( nil, listener )
end

function EventSystem:BroadcastEvent(eventname, ...)
    self.depth = self.depth + 1

    local listeners = self.tmp_listeners[ self.depth ]
    if listeners == nil then
        listeners = {}
        self.tmp_listeners[ self.depth ] = listeners
    end

    local event_listeners = self.listeners_by_event and self.listeners_by_event[eventname]

    if event_listeners then
        table.arrayadd( listeners, event_listeners )
    end
    for i = 1, #self.listeners, 3 do
        self:AddListenerToList( self.listeners[i], self.listeners[i+1], self.listeners[i+2], listeners )
    end
    -- listeners is processed in reverse order, so invert the list.
    table.reverse( listeners )

    while #listeners > 0 do
        local listener = table.remove( listeners )
        local fn = table.remove( listeners )
        local p = table.remove( listeners )
    	if type(fn) == "function" then
    		fn(listener, eventname, ...)
    	else
    		listener:OnGlobalEvent(eventname, ...)
    	end
    end
    table.clear( listeners )
    self.depth = self.depth - 1
end

function EventSystem:Clear()
    self.listeners_by_event = nil
    table.clear(self.listeners)
    table.clear(self.tmp_listeners)
    self.depth = 0
end

--------------------------------------------------
-- Event system with support for queued events.

class( "QueuedEventSystem", EventSystem )

function QueuedEventSystem:init()
    EventSystem.init( self )
    self.active_events, self.queued_events = {}, {}
end

function QueuedEventSystem:QueueEvent(eventname, ...)

    if select(1, ...) then
        table.insert( self.queued_events, { eventname, ... } )
    else
        table.insert( self.queued_events, eventname )
    end
end

function QueuedEventSystem:BroadcastQueuedEvents()
    self.active_events, self.queued_events = self.queued_events, self.active_events

    for i, event in ipairs( self.active_events ) do
        if type(event) == "table" then
            self:BroadcastEvent( table.unpack( event ))
        else
            self:BroadcastEvent(event)
        end
    end
    table.clear( self.active_events )
end

function QueuedEventSystem:Clear()
    EventSystem.Clear( self )
    table.clear(self.events)
    table.clear(self.active_events)
end

