print( "Startup!", world )

local agents = world:CreateBucketByClass( Agent.Shopkeeper )
for i, agent in ipairs( agents ) do
	local job = agent:GetAspect( Job.ManageShop )
	local shop = job.shop:GetAspect( Feature.Shop )
	if shop.shop_type == SHOP_TYPE.GENERAL then
		puppet:WarpToAgent( agent )
		break
	end
end

-- DBG(agent:GetAspect( Verb.Strategize ))