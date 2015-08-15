
if !GameTree then
	print("Where am I?")
	return
end

local function BuildMissile(pos)
	local Mis = ents.Create("ent_missile")

	Mis:SetPos(pos)
	Mis:SetModel("models/Cranes/crane_frame.mdl")
	Mis:PhysicsInit(SOLID_VPHYSICS)
	Mis:SetMoveType(MOVETYPE_FLY)
	Mis:SetSolid(SOLID_VPHYSICS)

	Mis:SetRenderMode( 4 )
	Mis:Spawn()

	Mis:SetNWFloat("Team",1)
end

RebleBase = nil
CombineBase = nil

hook.Add("MapScanComplete","BuildMap",function()
	--[[
	MapOBBMax = Vector(0,0,0)
	MapOBBMin = Vector(0,0,0)
	MapCenter = Vector(0,0,-10390)
	MapBoarder = 0.2
	]]
	local entz = ents.FindByClass("ent_baseship")
		table.Add(entz,ents.FindByClass("ent_missile"))
		table.Add(entz,ents.FindByClass("ent_ship"))
	for I=1,#entz do
		SafeRemoveEntity(entz[I])
	end
	print("Creating map entities..")

	local Reble = ents.Create( "ent_baseship" )
	local pos = MapOBBMin*(1-MapBoarder-0.1)
	pos.z = MapCenter.z+20
	Reble:SetPos(pos)
	Reble:Spawn()
	Reble:SetModel("models/Cranes/crane_frame.mdl")
	Reble:SetColor(Color(255,0,0))

	Reble:PhysicsInit(SOLID_VPHYSICS)
	Reble:SetMoveType(MOVETYPE_FLY)
	Reble:SetSolid(SOLID_VPHYSICS)

	Reble.Shield = 100
	Reble:SetHealth(100)
	Reble:SetNWFloat("Shield",100)

	RebleBase = Reble

	local Combine = ents.Create( "ent_baseship" )
	local pos = MapOBBMax*(1-MapBoarder-0.1)
	pos.z = MapCenter.z+20
	Combine:SetPos(pos)
	Combine:Spawn()
	Combine:SetModel("models/Cranes/crane_frame.mdl")
	Combine:SetColor(Color(0,0,255))

	Combine:PhysicsInit(SOLID_VPHYSICS)
	Combine:SetMoveType(MOVETYPE_FLY)
	Combine:SetSolid(SOLID_VPHYSICS)

	Combine.Shield = 100
	Combine:SetHealth(100)
	Combine:SetNWFloat("Shield",100)

	CombineBase = Combine

	-- Missiles
	local BaseCenter = (Combine:GetPos()-Reble:GetPos())/2+Reble:GetPos()
	BuildMissile(BaseCenter)

	local l = Combine:GetPos():Distance(BaseCenter)
	local a = (Combine:GetPos()-BaseCenter):Angle()
	local Silopos = BaseCenter+a:Forward()*l/2
	BuildMissile(Silopos)

	local l = Reble:GetPos():Distance(BaseCenter)
	local a = (Reble:GetPos()-BaseCenter):Angle()
	local Silopos = BaseCenter+a:Forward()*l/2
	BuildMissile(Silopos)


	local l = Reble:GetPos():Distance(BaseCenter)
	local a = (Reble:GetPos()-BaseCenter):Angle()
	local Silopos = BaseCenter+a:Right()*l/1.5
	BuildMissile(Silopos)

	local l = Combine:GetPos():Distance(BaseCenter)
	local a = (Reble:GetPos()-BaseCenter):Angle()
	local Silopos = BaseCenter+-a:Right()*l/1.5
	BuildMissile(Silopos)

	

end)