function Agent:MakeHuman()
	self.species = SPECIES.HUMAN

	self:MakeGendered()
	self:GainAspect( Aspect.Impass() )
end

function Agent:MakeOrc()
	self.species = SPECIES.ORC

	self:MakeGendered()
	self:GainAspect( Aspect.Impass() )
end

function Agent:MakeGendered()
	if math.random() < 0.5 then
		self.gender = GENDER.MALE
	else
		self.gender = GENDER.FEMALE
	end
end
