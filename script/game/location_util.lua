function Location.Connect( x, y )
	x:GainAspect( Feature.Portal( y ))
	y:GainAspect( Feature.Portal( x ))
end
