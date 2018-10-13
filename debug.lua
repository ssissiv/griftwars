

c = Creature.Fieldling()
world:AddCreature( c ):MoveToTile( cx, cy )

local tile = world.map:GetTile( cx, cy )
print( tile )
tile:DeltaProperty( TILE_PROP.CHAOS, 1 )
