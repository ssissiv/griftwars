local ChainMail = class( "Armour.ChainMail", Object.Armour )

ChainMail.image = assets.IMG.CHAINMAIL
ChainMail.defense_power = 6
ChainMail.desc = "A finely made mesh of chain links, good at deflecting most cutting attacks."
ChainMail.name = "chain mail"

function ChainMail:init()
	Object.Armour.init( self )
	self.value = 450
end
