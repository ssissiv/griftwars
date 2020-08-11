
local SellToShop = class( "Verb.SellToShop", Verb )

function SellToShop:init( actor, target, obj )
	Verb.init( self, actor )
	self.target = target
	self.obj = obj
end

function SellToShop:GetActDesc()
	return loc.format( "Sell {1} for {2#money}", self.obj, self:GetSellPrice() )
end

function SellToShop:FindTarget( actor )
	local targets = {}
	for i, obj in actor:GetLocation():Contents() do
		local job = obj:GetAspect( Job.ManageShop )
		if job then
			table.insert( targets, obj )
		end
	end
	-- sort by dist
	table.sort( targets, function( x, y ) return EntityDistance( x, actor ) < EntityDistance( y, actor ) end )
	return targets[1]
end

function SellToShop:CanInteract()
	local target = self.target or self:FindTarget( self.actor )
	if not target then
		return false
	end
	local job = target:GetAspect( Job.ManageShop )
	if not job:IsDoing() then
		local ok, reason = job:ShouldDo()
		if not ok then
			return false, reason
		else
			return false, "Not on the job"
		end
	end

	return Verb.CanInteract( self )
end

function SellToShop:GetSellPrice()
	local target = self.target or self:FindTarget( self.actor )
	if target then
		return target:GetAspect( Job.ManageShop ):GetSellCost( self.obj, self.actor )
	end
end

function SellToShop:Interact()
	local target = self.target or self:FindTarget( self.actor )
	local wearable = self.obj:GetAspect( Aspect.Wearable )
	if wearable then
		wearable:Unequip()
	end

	target:GetAspect( Job.ManageShop ):BuyFromSeller( self.obj, self.actor )
end
