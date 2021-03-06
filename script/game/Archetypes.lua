function Agent:MakeHuman()
	self.species = SPECIES.HUMAN

	self:MakeGendered()
	self:MakeBiological()
	self:GainAspect( Aspect.Impass( IMPASS.DYNAMIC ) )
end

function Agent:MakeOrc()
	self.species = SPECIES.ORC

	self:MakeGendered()
	self:MakeBiological()
	self:GainAspect( Aspect.Impass( IMPASS.DYNAMIC ) )
end

function Agent:MakeGnoll()
	self.species = SPECIES.GNOLL

	self:MakeGendered()
	self:MakeBiological()
	self:GainAspect( Aspect.Impass( IMPASS.DYNAMIC ) )
end

function Agent:MakeHillGiant()
	self.species = SPECIES.GIANT

	self:MakeGendered()
	self:MakeBiological()
	self:GainAspect( Aspect.Impass( IMPASS.DYNAMIC ) )
end

function Agent:MakeAnimal()
	self.species = SPECIES.MAMMAL

	self:MakeGendered()
	self:MakeBiological()
	self:GainAspect( Aspect.Impass( IMPASS.DYNAMIC ) )
end

function Agent:MakeGendered()
	if math.random() < 0.5 then
		self.gender = GENDER.MALE
	else
		self.gender = GENDER.FEMALE
	end
end

function Agent:MakeBiological()
	self:GainAspect( Aspect.HealthValue( self.max_health or 1, self.max_health or 1 ))
	local fatigue = self:CreateStat( STAT.FATIGUE, 0, 100, 0 )
	fatigue:SetThresholds( FATIGUE_THRESHOLDS )
	fatigue:DeltaRegen( 100 / (2 * ONE_DAY) )

	self:GainAspect( Aspect.Charisma( self.charisma or 1 ))
	self:GainAspect( Aspect.Strength( self.strength or 1 ))

	self:GainAspect( Verb.ManageFatigue( self ))
	self:GainAspect( Verb.Wander( self ) )
	self:GainAspect( Verb.Combat( self ) )
	self:GainAspect( Verb.HostileCombat( self ) )

	self:GainAspect( Aspect.Behaviour() )
end

