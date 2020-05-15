print( "Startup!", world )

local agent = table.arraypick( world:CreateBucketByClass( Object.JunkHeap ))
puppet:WarpToAgent( agent )

-- DBG(agent:GetAspect( Verb.Strategize ))