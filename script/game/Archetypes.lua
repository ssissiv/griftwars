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

function Agent:MakeAnimal()
	self.species = SPECIES.MAMMAL

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
	self:GainAspect( Aspect.HealthValue( 6, 6 ))
	self:CreateStat( STAT.FATIGUE, 0, 100 ):DeltaRegen( 100 / (2 * ONE_DAY) )
	self:CreateStat( STAT.CHARISMA, 1, 1 )
	self:GainAspect( Aspect.Strength( 1 ))

	self:GainAspect( Verb.ManageFatigue( self ))
	self:GainAspect( Verb.Idle() )
	self:GainAspect( Aspect.Combat() )
end
