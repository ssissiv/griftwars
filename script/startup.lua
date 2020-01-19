print( "SARTUP", world )

local scav = table.arraypick( world:CreateBucketByClass( Agent.Scavenger ))
puppet:WarpToAgent( scav )