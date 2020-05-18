print( "Startup!", world )

local agent = table.arraypick( world:CreateBucketByClass( Portal.AbandonedWell ))
puppet:WarpToAgent( agent )

-- DBG(agent:GetAspect( Verb.Strategize ))