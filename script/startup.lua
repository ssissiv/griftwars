print( "Startup!", world )

local agent = table.arraypick( world:CreateBucketByClass( Agent.Captain ))
puppet:WarpToAgent( agent )

DBG(agent:GetAspect( Verb.Strategize ))