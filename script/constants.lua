DEV = true

DBG_FLAGS = MakeBitField{ "RENDER" }

IMGUI =
{
	DEFAULT_OPEN = { "DefaultOpen" }
}


local colours =
{
	BLACK = { 0, 0, 0 },
	WHITE = { 255, 255, 255 },
	RED = { 255, 0, 0 },
	GREEN = { 0, 255, 0 },
	BLUE = { 0, 0, 255 },
	CYAN = { 0, 255, 255 },
	YELLOW = { 255, 255, 0 },
	MAGENTA = { 255, 0, 255 },

	--------------------------------
	-- UI colours

	PANEL_BG = { 0, 69, 112 },

	BTN_BG = { 100, 10, 10 },
	BTN_HOVER_BG = { 200, 20, 20 },
	BTN_CLICK_BG = { 255, 40, 40 },
	BTN_LABEL = { 220, 200, 200 },

	EMPTY_TILE = { 12, 24, 80 },
	EMPTY_ORIGIN = { 20, 32, 88 },

	----------------------------
	-- map colours

	FOOD = { 190, 50, 110 },
	LEVEL_BG = { 80, 120, 0 },
}


local buttons =
{
	MOUSE_LEFT = 1,
	MOUSE_MIDDLE = 2,
	MOUSE_RIGHT = 3,
}

local skins =
{
	BUTTON =
	{
		font = nil,
		label_colour = colours.WHITE,
		colour = colours.BTN_BG,
		hover_colour = colours.BTN_HOVER_BG,
		click_colour = colours.BTN_CLICK_BG,
		outline_colour = colours.BLACK,
	},
	ACTIVE_BUTTON =
	{
		font = nil,
		label_colour = colours.WHITE,
		colour = colours.BTN_CLICK_BG,
		hover_colour = colours.BTN_HOVER_BG,
		click_colour = colours.BTN_HOVER_BG,
		outline_colour = colours.BLACK,
	},
	COMBO_BUTTON =
	{
		left_align = true,
		font = nil,
		label_colour = colours.WHITE,
		colour = colours.BTN_BG,
		hover_colour = colours.BTN_HOVER_BG,
		click_colour = colours.BTN_CLICK_BG,
	},
	LABEL =
	{
		style = "default",
		colour = colours.WHITE,
	},
	HEADER =
	{
		style = "header",
		colour = colours.WHITE,
	},
	SLIDER =
	{
		colour = colours.RED,
		hover_colour = colours.BTN_HOVER_BG,
		click_colour = colours.BTN_HOVER_BG,
		bg_colour = { 20, 10, 10 },
	}
}

return strictify
{
	colours = colours,
	skins = skins,
	buttons = buttons,
}
