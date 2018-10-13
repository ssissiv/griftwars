-- Tests is_class and is_instance implementations within class.lua.
require "util/class"

print( "TESTING..." )

local Super = class( "_Base" )
Super.can_reload = true
local SubA = class( "_SubA", _Base )
SubA.can_reload = true
local SubB = class( "_SubB", _Base )
SubB.can_reload = true
local SubSubA = class( "_SubSubA", _SubA )
SubSubA.can_reload = true

-- Test is_class false values.
assert( is_class() == false)
assert( is_class(0) == false)
assert( is_class(string) == false)
assert( is_class("string") == false)
assert( is_class(Super()) == false)
assert( is_class(SubA()) == false)
assert( is_class(SubSubA()) == false)
assert( is_class(getmetatable(SubA)) == false)

-- Test is_class true values
assert( is_class(Super) == true)
assert( is_class(SubA) == true)
assert( is_class(SubSubA) == true)

-- Test is_instance false values
assert( is_instance() == false )
assert( is_instance( 1, 2 ) == false )
assert( is_instance( Super, Super ) == false )
assert( is_instance( SubA, Super ) == false )
assert( is_instance( SubSubA, Super ) == false )
assert( is_instance( Super, nil ) == false )
assert( is_instance( Super, 0 ) == false )
assert( is_instance( Super, string ) == false )
assert( is_instance( SubA, Super() ) == false )
assert( is_instance( SubA(), SubA() ) == false )
assert( is_instance( SubA(), Super() ) == false )
assert( is_instance( SubSubA(), SubB ) == false )
assert( is_instance( SubA(), SubSubA ) == false )

-- Test is_instance true
assert( is_instance( Super() ) == true )
assert( is_instance( Super(), Super ) == true )
assert( is_instance( SubA(), Super ) == true )
assert( is_instance( SubB(), Super ) == true )
assert( is_instance( SubSubA(), SubA ) == true )
assert( is_instance( SubSubA(), Super ) == true )

print( "\t<#00FF00>DONE</>" )
