local Intel = class( "Aspect.Intel", Aspect )

function Intel:init( desc )
	self.desc = desc
end

function Intel:AddSpeech( speech )
	if self.speech == nil then
	end
end

function Intel:OnSpawn( world )
	Aspect.OnSpawn( self, world )

	-- self:AddAspect( Aspect.Intel( Engram.Discovered( exit:GetDesc() )))
	world:ListenForEvent( CALC_EVENT.COLLECT_INTEL, self, self.OnCollectIntel )
end

function Intel:OnCollectIntel( event_name, world, acc )
	acc:AppendValue( Engram.Discovered( self.owner, self.desc ))
end
