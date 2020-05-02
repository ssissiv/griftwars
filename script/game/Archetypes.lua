function Agent:MakeHuman()
	self.species = SPECIES.HUMAN

	self:MakeGendered()
	self:MakeBiological()
	self:GainAspect( Aspect.Impass() )
end

function Agent:MakeOrc()
	self.species = SPECIES.ORC

	self:MakeGendered()
	self:MakeBiological()
	self:GainAspect( Aspect.Impass() )
end

function Agent:MakeGendered()
	if math.random() < 0.5 then
		self.gender = GENDER.MALE
	else
		self.gender = GENDER.FEMALE
	end
end

function Agent:MakeBiological()
	self:GainAspect( Verb.ManageFatigue( self ))
	self:GainAspect( Verb.Idle() )
	self:GainAspect( Aspect.Combat() )
end
