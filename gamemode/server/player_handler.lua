
local meta = FindMetaTable("Player")
function meta:EnterShip(ent)
	if !ent then return false end
	if ent:GetClass()!="ent_ship" then
		return false,"I'm not a ship"
	end
	-- Anyone in it?
	if ent.Driver then return false,"I got an owner" end
	-- Are you driving?
	if self.Driving then return false,"You can drive two things" end
	-- gooood
	local model = self:GetModel()
	ent.Driver = self
	self.Driving = ent
	self:Spectate( OBS_MODE_CHASE )
 	self:SpectateEntity( ent, true )
 	self:StripWeapons()
 	ent:SetNWEntity("Driver",self)
 	ent:SetNWString("DriverModel",model)

 	return true
end

function meta:LeaveShip()
	if !gmod.GetGamemode().Debug then -- This is a debug function .. don't leave your ship in the middle of the skies
		return false
	end
	local ent = self.Driving
	self:UnSpectate()
 	self:Spawn()
 	self:SetPos(ent:GetPos()+Vector(0,0,10))
 	ent.Driver = nil
	self.Driving = nil
	ent:SetNWString("Driver","")
 	ent:SetNWString("DriverModel","")
end

function GM:PlayerCanHearPlayersVoice( listener, talker )
	return ( listener:Team() ==  talker:Team() )
end

hook.Add("KeyPress","PressFix",function( ply, key )
	if ( key == IN_LEFT ) then
		ply.Left = true
	end
	if ( key == IN_RIGHT ) then
		ply.Right = true
	end
	if ( key == IN_FORWARD ) then
		ply.Up = true
	end
	if ( key == IN_BACK ) then
		ply.Down = true
	end
	if ( key == IN_JUMP ) then
		ply.Space = true
	end
	if ( key == IN_JUMP ) then
		ply.Space = true
	end
end)

hook.Add("KeyRelease","PressFix2",function( ply, key )
	if ( key == IN_LEFT ) then
		ply.Left = false
	end
	if ( key == IN_RIGHT ) then
		ply.Right = false
	end
	if ( key == IN_FORWARD ) then
		ply.Up = false
	end
	if ( key == IN_BACK ) then
		ply.Down = false
	end
	if ( key == IN_JUMP ) then
		ply.Space = false
	end

end)

hook.Add("SetupMove","ShipMove",function(ply,mv,cmd)
	if 1+1==2 then
		return false
	end
	local ent = ply.Driving
	if type(ent)=="nil" then return end
	if ent:GetClass()!="ent_ship" then return end

	local Buttenz = cmd:GetButtons()
	
	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then return end
	if phys:IsGravityEnabled() then
		phys:EnableGravity(false)
	end

	-- Goddamnit .. can only get 1 key
	if 1+1==2 then
		return false
	end
	local SPACE = cmd:KeyDown( IN_JUMP )
	
	local yaw = 0
	local pitch = 0
	local roll = ent:GetAngles().roll
	if A then 
		yaw = yaw+20 
		roll = roll-30
	end
	if D then 
		yaw = yaw-20 
		roll = roll+30
	end

	if W then pitch = pitch+20 end
	if S then pitch = pitch-20 end


	local angleforce = ent:LocalToWorldAngles(Angle(0,yaw+180,0))

	local Speeddata = ent.Data.speed -- first is max .. last is min
	local min,max = Speeddata[2] or 0,Speeddata[1]
	local Acc = ent.Data.acc
	
	local Gas = ent.Gas or 0
	if SPACE then
		Gas = math.min(Gas+Acc,max)
	else
		Gas = math.max(Gas-Acc/1.7,min)
	end
	ent.Gas = Gas
	ply:SetNWFloat("ShipGas",Gas)

	local GasLength = (max-min)*Gas
	local TotalGas = min+GasLength


	local VelGas = -ent:GetAngles():Forward()*Vector(TotalGas*10,0,0)
	
	local v = LerpVector(0.2,phys:GetVelocity(),VelGas)
	phys:SetVelocity(angleforce:Forward()*TotalGas*0)
		phys:AddAngleVelocity( Vector(-roll,pitch,yaw) )

	ply:SetNWFloat("ShipSpeed",curspeed)
	ply:SetNWFloat("Yaw",yaw)
	ply:SetNWFloat("Pitch",pitch)

	ply:SetNWVector("ShipVel",phys:GetVelocity()*20)
	
end)