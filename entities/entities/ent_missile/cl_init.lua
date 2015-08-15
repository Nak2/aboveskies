
include("shared.lua")


function ENT:Initialize()
	self.Part = ""
end

function ENT:Think()
	
end

function ENT:OnRemove( )
	
end

function ENT:Draw()
	render.MaterialOverride(Material("phoenix_storms/OfficeWindow_1-1"))
	self:DrawModel()
	render.MaterialOverride()
end


