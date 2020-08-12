local ResourceGenerator = class( "Aspect.ResourceGenerator", Aspect )

function ResourceGenerator:init( class )
	assert( class._classname )
	self.class_name = class._classname
end

function ResourceGenerator:IsGenerator( class )
	return class._classname == self.class_name
end

