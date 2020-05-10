print( "Startup!", world )

local agent = table.arraypick( world:CreateBucketByClass( Agent.Orc ))
puppet:WarpToAgent( agent )

-- DBG(agent:GetAspect( Verb.Strategize ))