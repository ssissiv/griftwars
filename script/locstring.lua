----------------------------------------------------------------
-- Localization functions.

local loc = require "locmacros"

-- Converts a plurality (integer) to an index.
-- TODO: this is parameterized by the locale, through the .pot file.
local function convertPlurality( n )
    return (n ~= 1 and n ~= -1) and 2 or 1
end

local function consume_token( str )
	local i, j, w, rest = str:find( "^([^|}]+)[|}]?(.*)" )
	return w, rest
end

-- Localization formatter which should be used exclusively to compose all localized strings.  Each
-- format specifier (a parameter index enclosed in curly braces) can take multiple forms.
-- Note that the location of the specifiers within the format string is immaterial, since they
-- directly refer to the relevant parameter's index.
-- In the examples below, replace 'n' with the 'nth' parameter (not including the format string).
--
-- {n} : replaced with tostring(n)
-- loc.format( "I am a formatted {1}", "string" ) --> "I am a formatted string"

-- {n:word1|word2|...} : replaced with word<n>, so that n indexes into the pipe-delineated list.
-- loc.format( "I choose you, {1:Pikachu|Squirtle}!", 1 ) --> "I choose you, Pikachu!"
--
-- {n*plural1|plural2|...} : replaced with word<i>, where i == convertPlurality(n), so that n is
--      an integral number of something, which is converted into an index into the pipe-delineated list.
--      The plurality function is customizable per locale.
-- loc.format( "I ate {1*an|some} {1*apple|apples}", 1 ) --> "I ate an apple"
--
-- {n.field} : replaced with n[ field ], so that n is a table of strings indexxed by the fieldname.
--      In the example below, DECKER = { name = "Decker", hisher = "his" }.
-- loc.format( "{1.name} hurt {1.hisher} hand", DECKER ) --> "Decker hurt his hand"
--
-- {n%format} : replaced with string.format( format, n )
-- loc.format( "Pi to 2 places: {1%.2f}", math.pi ) --> "Pi to 2 places: 3.14"
--
-- {n#macro_fn} : replaced with macro_fn( n )
-- loc.format( "Happy {1#time} to you!", gs:GetDateTime() ) --> "Happy 6:05 am to you!"

function loc.format( format, ... )
    if type(format) == "table" then
        format = table.concat( format )
    end
	for i = 1, select("#", ...) do
		local v = select(i, ... )
		local j, k, fn, options
		repeat
			j, k, fn, options = format:find( "{"..i.."([:*.%%#]?)([^}]-)}", (k or 0) + 1 )
			local substr
			if fn == "*" then
                -- v is a plurality, which converts to an index into options
                local pluralForm = convertPlurality( v )
				local option
				for n = 1, pluralForm do
					option, options = consume_token( options )
					if not option then break end
				end
				substr = tostring(option)
            elseif fn == ":" then
                -- v is an index into options
                local option
				for n = 1, v do
					option, options = consume_token( options )
					if not option then break end
				end
				substr = tostring(option)
            elseif fn == '.' then
                -- v is a table, options is the field-name.
                if v.LocTable then
            		v = v:LocTable()
                end
                substr = tostring( v[ options ] )
            elseif fn == '%' then
            	substr = string.format( "%"..options, v )
            elseif fn == '#' then
            	substr = (loc[ options ] and loc[ options ]( v ) or options)
			elseif j then
				substr = tostring(v)
			end
			if substr then
				format = format:sub( 1, j - 1 ) .. substr .. format:sub( k + 1 )
				k = j + #substr
			end
		until not j
	end
	return format
end

function loc.cap( str )
	return loc.toupper( str:sub( 1, 1 ) ) .. str:sub( 2 )
end

function loc.decap( str )
	return loc.tolower( str:sub( 1, 1 ) ) .. str:sub( 2 )
end

function loc.toupper( str )
	-- FIXME: non-unicode garbage
	return str:upper()
end

function loc.tolower( str )
	-- FIXME: non-unicode garbage
	return str:lower()
end

return loc