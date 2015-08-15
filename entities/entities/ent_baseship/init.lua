AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	
end

function ENT:Think()
	if self:Health()<1 then
		if (self.Ex or 0)<SysTime() then
			self.Ex = SysTime()+math.random(2)
			local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos()+Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)) )
			util.Effect( "HelicopterMegaBomb", effectdata )

		end
	end
end

function ENT:Use()
	
end