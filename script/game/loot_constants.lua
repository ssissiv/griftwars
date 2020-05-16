local rng = math.random

LOOT_JUNK_T1 =
{
	function()
		return Object.Creds( rng( 1, 3 ))
	end, 1,
	function()
		return Object.Jerky()
	end, 1,
	nil_function, 5,
}


LOOT_JUNK_T2 =
{
	function()
		return Object.Creds( rng( 1, 3 ))
	end, 1,
	function()
		return Object.Creds( rng( 3, 5 ))
	end, 1,
	function()
		return Object.Jerky()
	end, 1,
	nil_function, 3,
}


LOOT_JUNK_T3 =
{
	function()
		return Object.Creds( rng( 2, 4 ))
	end, 1,
	function()
		return Object.Creds( rng( 6, 8 ))
	end, 1,
	function()
		return Object.Jerky(), Object.Jerky()
	end, 1,
	nil_function, 2,
}
