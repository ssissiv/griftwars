--Linear Congruential Generator
--https://github.com/linux-man/randomlua

-- The MIT License (MIT)

-- Copyright (c) 2016 linux-man

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local function normalize(n) --keep numbers at (positive) 32 bits
	return n % 0x80000000
end

local function seed()
	--return normalize(tonumber(tostring(os.time()):reverse()))
	return normalize(os.time())
end


linear_congruential_generator = {}
linear_congruential_generator.__index = linear_congruential_generator

function linear_congruential_generator:random(a, b)
	local y = (self.a * self.x + self.c) % self.m
	self.x = y
	if not a then return y / 0xffff
	elseif not b then
		if a == 0 then return y
		else return 1 + (y % a) end
	else
		return a + (y % (b - a + 1))
	end
end

function linear_congruential_generator:randomseed(s)
	if not s then s = seed() end
	self.x = normalize(s)
end

function lcg(s, r)
	local temp = {}
	setmetatable(temp, linear_congruential_generator)
	temp.a, temp.c, temp.m = 1103515245, 12345, 0x10000  --from Ansi C
	if r then
		if r == 'nr' then temp.a, temp.c, temp.m = 1664525, 1013904223, 0x10000 --from Numerical Recipes.
		elseif r == 'mvc' then temp.a, temp.c, temp.m = 214013, 2531011, 0x10000 end--from MVC
	end
	temp:randomseed(s)
	return temp
end


