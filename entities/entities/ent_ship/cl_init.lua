
include("shared.lua")

local msin = math.sin
local mcos = math.cos

function ENT:Initialize()
	self.Part = ""
end

function ENT:Think()
	
end

function ENT:OnRemove( )
	if self.DriverModel then
		SafeRemoveEntity(self.DriverModel)
	end
end

function ENT:Draw()
	self:DrawModel()
	--[[self:SetNWString("Driver",self:GetName())
 	self:SetNWString("DriverModel",model)]]
 	local ply = self:GetNWEntity("Driver")
 	if type(ply)=="Player" then
 		local n = ply:Nick()
 		local EYANG =  EyeAngles()
	 		EYANG:RotateAroundAxis(EYANG:Forward(),90)
	 		EYANG:RotateAroundAxis(EYANG:Right(), -270)
 		cam.Start3D2D(self:GetPos()+Vector(0,0,self:OBBMaxs().z+50),EYANG,0.5)
 			surface.SetTextColor(Color(255,255,255))
 			surface.SetFont("Default")
 			local NL,NH = surface.GetTextSize(n)
 			surface.SetDrawColor(Color(0,0,0))
 			local w = 20+NL
 			surface.DrawRect(-w/2,0,w,NH+1)
 			surface.SetTextPos(-NL/2,0)
 			surface.DrawText(n)
 		cam.End3D2D()
 	end
 	local model = self:GetNWString("DriverModel","")

 	if #model>0 then
 		if type(self.DriverModel)!="CSEnt" then
 			local scale = gmod.GetGamemode().Scale or 1
 			self.DriverModel = ClientsideModel(model,"RENDERGROUP_OTHER")
 			local ent = self.DriverModel
 			local SP = self:GetNWVector("Seat",Vector(0,0,0))
 			ent:SetPos(self:LocalToWorld(SP))
 			ent:SetAngles(self:LocalToWorldAngles(Angle(0,180,0)))
 			ent:SetParent(self)
 			 			
 			if scale!=1 then
 				ent:SetModelScale(scale,0)
 			end

 			local iSeq = ent:LookupSequence("drive_jeep")
 			print(iSeq)
 			ent:ResetSequence(iSeq)

 				ent:SetFlexWeight(1,1)
 				ent:SetFlexWeight(2,1)
 			for I=3,9 do
 				ent:SetFlexWeight(I,0)
 			end
 			--sit_rollercoaster
 		end
 	elseif type(self.DriverModel)=="CSEnt" then
 		SuperSafeRemoveEntity(self.DriverModel)
 		self.DriverModel = nil
 	end
end


