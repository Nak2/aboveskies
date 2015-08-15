AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local mat = Material("phoenix_storms/FuturisticTrackRamp_1-2")
function ENT:Initialize()
	local ent = ents.Create("prop_dynamic")
	ent:SetModel("models/props_doomsday/rocket_socket_doomsday.mdl")
	ent:SetPos(self:LocalToWorld(Vector(80,0,469)))
	ent:SetAngles(self:LocalToWorldAngles(Angle(0,90,0)))
	ent:Spawn()
	ent:SetParent(self)
	ent:SetModelScale(0.25)

	local ent2 = ents.Create("prop_dynamic")
	ent2:SetModel("models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl")
	ent2:SetPos(self:LocalToWorld(Vector(0,0,464)))
	ent2:SetAngles(self:LocalToWorldAngles(Angle(270,0,0)))
	ent2:Spawn()
	ent2:SetMaterial(mat)
	ent2:SetModelScale(8)
	ent2:SetColor(Color(120,120,120))
	ent2:SetParent(self)
	
	self.Missile = ent2

	self.Team = 0
	self.CapturePower = 0
	self.Power = 0
	self.PT = 0
	self:SetNWFloat("Power",0)
	self:SetNWFloat("CapPower",0)
	self.C = 0
end

function ENT:Launch()
	local target = nil
	if self.Team == 2 then
		target = CombineBase
	elseif self.Team == 3 then
		target = RebleBase
	end
	if !target then return end -- ehhhh
	local mis = ents.Create("ent_hitmissile")
	mis:SetModel("models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl")
	mis:SetPos(self:LocalToWorld(Vector(0,0,464)))
	
	mis:SetAngles(self:LocalToWorldAngles(Angle(270,0,0)))
	
	mis.Target = target
	mis:PhysicsInit(SOLID_VPHYSICS)
	mis:SetMoveType(MOVETYPE_VPHYSICS)
	mis:SetSolid(SOLID_VPHYSICS)

	mis:Spawn()
	local startWidth,endWidth = 80,30
	util.SpriteTrail( mis, 0, Color(255,255,255), 1, startWidth, endWidth, 4, 1 / ( startWidth + endWidth ) * 0.5 , "trails/smoke.vmt" )
	self:EmitSound("misc/doomsday_missile_launch.wav")
	mis:SetModelScale(8)
end

function ENT:Think()
	if (self.C or 0)>SysTime() then return end
	self.C = SysTime()
	if (self.PT or 0)<SysTime() then
		self.PT = SysTime()+2
		if self.Team==2 or self.Team == 3 then
			self.Power = math.min((self.Power or 0)+0.1,1)
			if self.Power>=1 then
				self.Power = 0
				self:Launch()
			end
			self:SetNWFloat("Power",self.Power)
		end
	end

	local Ships = ents.FindByClass("ent_ship")
	local AimAt = -1
	for I=1,#Ships do
		if Ships[I]:GetPos():Distance(self:GetPos())<1250 then
			local t = Ships[I].Team or 0
			if AimAt<0 then
				AimAt = t
			elseif AimAt!=t then
				AimAt = 0
			end
		end
	end
	if AimAt>-1 and AimAt!=self.Team then
		-- Something about to happen
		self.CapturePower = self.CapturePower+0.01
		if self.CapturePower<1 then
			self:SetNWFloat("CapPower",self.CapturePower)
		else
			self.Team = AimAt
			self:SetNWFloat("Team",self.Team)
			self.CapturePower = 0
			self:SetNWFloat("CapPower",0)
			if AimAt!=0 then
				self:EmitSound("ambient/machines/thumper_startup1.wav")
			else
				self:EmitSound("ambient/machines/thumper_shutdown1.wav")
			end
			hook.Call("CapPoint",_,self)
		end
	elseif self.CapturePower>0 then
		self.CapturePower = math.max(self.CapturePower-0.05,0)
		self:SetNWFloat("CapPower",self.CapturePower)
	end

	--self:SetNWFloat("Team",math.random(1,3))
end

function ENT:Use()
	
end