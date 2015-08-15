AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local abs = math.abs

function ENT:Initialize()
	self.Handle = 40
end

local function SetAngleVel(vel,self)
	self:AddAngleVelocity(-self:GetAngleVelocity() + vel)
end

function ENT:OnTakeDamage( ctd )
	local att = ctd:GetAttacker()
	local AtBase = false
	if self.Team==2 and RebleBase.Shield > 0 then
		if self:GetPos():Distance(RebleBase:GetPos())<2000 then
			AtBase = true
		end
	elseif self.Team == 3 and CombineBase.Shield > 0 then
		if self:GetPos():Distance(CombineBase:GetPos())<2000 then
			AtBase = true
		end
	end

	if att:Team() == self.Team then
		ctd:SetDamage(0)
		print("Team shoot")
	elseif AtBase then
		ctd:SetDamage(0)

	else
		self:SetHealth(self:Health()-ctd:GetDamage())
	end

end

function ENT:OnRemove()
	--self.MS
	if type(self.MS)=="CSoundPatch" then
		self.MS:Stop()
		self.MS = nil
	end
end

function ENT:Think()
	if !self.Driver then return end

	local ply = self.Driver
	if self:Health()<1 then
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "HelicopterMegaBomb", effectdata )

		
		self:Remove()
		if self.Driver then
			self.Driver.CanSpawn = SysTime()+10
			self.Driver:AddDeaths(1)
			self.Driver:KillSilent()
		end
	end
	local phys = self:GetPhysicsObject()
	ply:SetPos(self:GetPos())
	if type(self.MS)!="CSoundPatch" then
		self.MS = CreateSound(self,"weapons/cow_mangler_idle.wav",ply)
		self.MS:Play()
	else
		if !self.MS:IsPlaying() then
			self.MS:Play()
			self.MS:ChangeVolume( 0.5,0 )
		end
		self.MS:ChangePitch( 10+math.min(155,self:GetVelocity():Length()/10), 0 )
	end

	if !IsValid(phys) then return end

	local W,A,S,D = ply.Up or false,ply.Left or false,ply.Down or false,ply.Right or false
	
	local SPACE = ply.Space
	local FIRE = ply:KeyDown( IN_ATTACK )

	local Ang = self:GetAngles()
	local Vel = Vector(0,0,0)
	--LerpAngle(0.2, CurrentAngle, TargetAngle)
	
	if A and !D then
		Vel.z = Vel.z+(self.Handle or 1)*2
	elseif D and !A then
		Vel.z = Vel.z-(self.Handle or 1)*2
	end
	if W and !S then
		Vel.y = Vel.y+(self.Handle or 1)
	elseif S and !W then
		Vel.y = Vel.y-(self.Handle or 1)
	end

	local face = ply:EyeAngles()
	local Pitch = math.AngleDifference( -Ang.p, face.p )*2
	local Yaw = math.AngleDifference( Ang.y, face.y+180 )

	local VelAng = LerpAngle( self.Handle/100, self:GetAngles(), face )

	-- Roll,Pitch, Yaw
	local Vel = Vector(-Ang.r-(Yaw/2),Pitch,-Yaw)

	SetAngleVel(Vel,phys)

	local Speeddata = self.Data.speed -- first is max .. last is min
	local min,max = Speeddata[2] or 0,Speeddata[1]
	local Acc = self.Data.acc*7
	local Gas = self.Gas or 0
	if SPACE then
		Gas = math.min(Gas+Acc,max)
	else
		Gas = math.max(Gas-Acc/1.7,min)
	end
	self.Gas = Gas
	ply:SetNWFloat("ShipGas",Gas)
	local GasLength = (max-min)*Gas
	local TotalGas = min+GasLength

	local VelGas = -Ang:Forward()*Vector(TotalGas*10,0,0)
	
	local vel = Ang:Forward()*-TotalGas*2
	if self:GetPos().z<MapCenter.z+100 then
		vel.z = math.max(vel.z,10)
	elseif self:GetPos().z>MapCenter.z+1200 then
		vel.z = math.min(vel.z,0)
	end
	phys:SetVelocity(vel)

	if FIRE then
		if (self.Whine or 0)<1 then 
			if self.Whine==0 then
				if type(self.WS)!="nil" then
					self.WS:Stop()
					self.WS = nil
				end
				self.WS = CreateSound(ply,"weapons/minigun_wind_up.wav",self:EntIndex())
				self.WS:Play()
			end
			self.Whine = math.min((self.Whine or 0)+FrameTime()*15,1)
		else
			if self.Whine==1 then
				self.Whine = 1.1
				if type(self.WS)!="nil" then
					self.WS:Stop()
					self.WS = nil
				end
				self.WS = CreateSound(ply,"weapons/minigun_shoot.wav",self:EntIndex())
				self.WS:Play()

			end
		end
	elseif (self.Whine or 0)>0 then
		if type(self.WS)!="nil" then
			self.WS:Stop()
			self.WS = nil
		end
		self.Whine = 0
		self.WS = CreateSound(ply,"weapons/minigun_wind_down.wav",self:EntIndex())
		self.WS:Play()
	end

	if (self.Whine or 0)>1 then
		
		-- shoot :o
		local Damage = self.Data.DM or 0
		if type(Damage)=="table" then
			Damage = math.random(Damage[1],Damage[2])
		end

		local bullet = {}
		bullet.Attacker = ply
		bullet.Num=3
		bullet.Src=self:GetPos()
		bullet.Dir=ply:EyeAngles():Forward()
		bullet.Spread=Vector(0.05,0.05,0)
		bullet.Tracer=1	
		bullet.Force=2
		bullet.Damage=Damage*1.2
		bullet.Distance = 3000
		self:FireBullets(bullet)

	end
	if (self.EC or 0) <SysTime() then
		self.EC = SysTime()+1
		local m = (1-MapBoarder)
		local max,min = Vector(MapOBBMax.x*m,MapOBBMax.y*m,MapOBBMax.z),Vector(MapOBBMin.x*m,MapOBBMin.y*m,MapCenter.z)

		if not self:GetPos():WithinAABox(min,max) then
			self:SetHealth(self:Health()-15)
		else
			local AtBase = false
			if self.Team==2 then
				if self:GetPos():Distance(RebleBase:GetPos())<2000 then
					AtBase = true
				end
			elseif self.Team == 3 then
				if self:GetPos():Distance(CombineBase:GetPos())<2000 then
					AtBase = true
				end
			end
			if AtBase then
				self:SetHealth(math.min(100,self:Health()+5))
			end
		end
	end
end

function ENT:Use(ply)
	if !ply or type(ply)!="Player" then return end
	local succ,msg = ply:EnterShip(self)
	if !succ then
		ply:ChatPrint(msg)
	end
end
