-- Tests various garbge collection timings.

print( "TESTING..." )

local count = 1000 * 1000 * 10
local tt = "table"

local t = os.clock()
local m = {}
for i = 1, count do
	if tt == "string" then
		m[i] = string.char( math.random( 65, 65 + 26 ), math.random( 65, 65 + 26 ), math.random( 65, 65 + 26 ) )
	elseif tt == "number" then
		m[i] = math.random( 10000 )
	elseif tt == "table" then
		m[i] = {}
	end
end
print( "Made " .. tt .. " garbage took: ", (os.clock() - t))

local t = os.clock()
collectgarbage( "collect" )
print( "GC 1 took: ", (os.clock() - t))

m = nil

local t = os.clock()
collectgarbage( "collect" )
print( "GC 2 took: ", (os.clock() - t))
