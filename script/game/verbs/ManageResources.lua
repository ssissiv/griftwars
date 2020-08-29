-- ResourceManaging tries to balance resources by finding sources.

local ManageResources = class( "Job.ManageResources", Job )

function ManageResources:OnInit()
	self:SetShiftHours( 0, 24 )
end

function ManageResources:SetResourceOwner( ent )
	self.resource_owner = ent
end

function ManageResources:CalculateImportantResource()
	local best_ratio, best_resource
	for i, aspect in self.resource_owner:Aspects() do
		if is_instance( aspect, Aspect.Resource )then
			local target = aspect:GetTargetValue()
			local value, max_value = aspect:GetValue()
			local ratio = (target - value) / max_value
			if best_ratio == nil or ratio > best_ratio then
				best_ratio, best_resource = ratio, aspect
			end
		end
	end

	return best_resource, best_ratio
end


function ManageResources:RenderAgentDetails( ui, screen, viewer )
	if self.resource_owner then
		ui.Text( "Managing:" )
		ui.Indent( 20 )
		for i, aspect in self.resource_owner:Aspects() do
			if is_instance( aspect, Aspect.Resource ) then
				aspect:RenderAgentDetails( ui, screen, viewer )
				ui.SameLine( 0, 10 )
				if aspect:GetTargetValue() then
					ui.Text( loc.format( "Target: {1}", aspect:GetTargetValue() ))
				end
			end
		end
		ui.Unindent( 20 )
	end
end

function ManageResources:Interact()
	while true do
		self:YieldForTime( ONE_HOUR )
	end
end

function ManageResources:GetDesc()
	local desc = loc.format( "Managing Resources for {1}", self.resource_owner )
	return desc
end
