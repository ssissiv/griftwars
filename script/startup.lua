print( "Startup!", world )

function WarpToShop()
	local agents = world:CreateBucketByClass( Agent.Shopkeeper )
	for i, agent in ipairs( agents ) do
		local job = agent:GetAspect( Job.ManageShop )
		local shop = job.shop:GetAspect( Feature.Shop )
		if shop.shop_type == SHOP_TYPE.GENERAL then
			puppet:WarpToAgent( agent )
			break
		end
	end
end

function WarpToWell()
	local obj = table.arraypick( world:CreateBucketByClass( Portal.AbandonedWell ))
	puppet:WarpToLocation( obj.location )
end

WarpToWell()

-- DBG(agent:GetAspect( Verb.Strategize ))