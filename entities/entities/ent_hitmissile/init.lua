AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	
end

local function SetAngleVel(vel,self)
	self:AddAngleVelocity(-self:GetAngleVelocity() + vel)
end

function ENT:Think()
	if type(self.Target)=="nil" or !self.Target:IsValid() then 
		--boom
		self:Remove()
		return
	end
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		if phys:IsGravityEnabled() then
			phys:EnableGravity(false)
			phys:SetMass( 1000 )
		end
	end
	local dis = 200
	self.speed = math.min((self.speed or 0)+10,600)
	if self.Target.Shield or 0 > 0 then
		dis = 1800
	end
	local rldis = self:GetPos():Distance(self.Target:GetPos())
	if rldis <=dis then
		-- BOOOM
		if self.Target.Shield>0 then
			self.Target.Shield = math.max(0,self.Target.Shield-20)
			self.Target:SetNWFloat("Shield",self.Target.Shield)
		else
			local hp = self.Target:Health()-20
			self.Target:SetHealth(hp)
			local pl = player.GetAll()
			local msg = "TEAM base is at "..hp.."%"
			if self.Target.Team == 2 then
				msg = string.Replace(msg,"TEAM","Rebles")
			end
			if self.Target.Team == 3 then
				msg = string.Replace(msg,"TEAM","Combines")
			end

			for I=1,#pl do
				pl[I]:PrintMessage(HUD_PRINTCENTER,msg)
			end
		end
		local s = CreateSound( self.Target, "ambient/explosions/explode_"..math.random(1,3)..".wav", self.Target:EntIndex() )
		s:Play()
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "HelicopterMegaBomb", effectdata )

		self.Target = nil
	else
		-- Aim and keep on
		local AA = (self.Target:GetPos()-self:GetPos()):Angle()
		local sang = LerpAngle( 0.05+(self.speed/6000), self:GetAngles(), AA )
		self:SetAngles(sang)
		self:SetPos(self:GetPos()+self:GetAngles():Forward()*self.speed)
	end
end

function ENT:Use()
	
end