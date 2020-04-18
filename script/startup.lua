print( "Startup!", world )

local agent = table.arraypick( world:CreateBucketByClass( Agent.Shopkeeper ))
puppet:WarpToAgent( agent )

-- DBG(agent:GetAspect( Verb.Strategize ))