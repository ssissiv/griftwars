local Input = class( "Input" )

Input.LEFT_MOUSE = 1
Input.RIGHT_MOUSE = 2
Input.MIDDLE_MOUSE = 3

function Input.IsShift()
	return love.keyboard.isDown( "lshift" ) or love.keyboard.isDown( "rshift" )
end

function Input.IsControl()
	return love.keyboard.isDown( "lctrl" ) or love.keyboard.isDown( "rctrl" ) 
            or love.keyboard.isDown( "lgui" ) or love.keyboard.isDown( "rgui" ) 
end

function Input.IsAlt()
	return love.keyboard.isDown( "lalt" ) or love.keyboard.isDown( "ralt" )
end

function Input.IsModifierDown()
    return Input.IsShift() or Input.IsControl() or Input.IsAlt()
end

-------------------------------------------------------------------------------------

local InputBinding = class( "InputBinding" )

function InputBinding:init( t )
    assert( t.key ~= nil )
    for k, v in pairs( t ) do
        self[k] = v
    end
end


function InputBinding:CheckModifiers()
    if self.SHIFT and not Input.IsShift() then
        return false
    end
    if self.CTRL and not Input.IsControl() then
        return false
    end
    if self.ALT and not Input.IsAlt() then
        return false
    end
    return true
end

function InputBinding:CheckBinding( key )
    return key == self.key and self:CheckModifiers()
end

function InputBinding:GetBindingString()
    -- TODO: refer to properly localized key names.
    local str = ""
    if self.CTRL then
        str = str.."CTRL-"
    end
    if self.SHIFT then
        str = str.."SHIFT-"
    end
    if self.ALT then
        str = str.."ALT-"
    end
    if self.key then
        str = str .. self.key
    end
    return str
end



