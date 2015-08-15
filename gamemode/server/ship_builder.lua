
Ships = {}
local ShipFiles	= file.Find(GM.FolderName .. "/gamemode/ships/*.lua","LUA")

function AddShip(name,data)
	Ships[name] = data
end

MsgN('// Adding ships: ')
for k, fl in pairs(ShipFiles) do
	include(GM.FolderName .. "/gamemode/ships/" .. fl)
	MsgN('//	-'.. fl)
end
AddShip = nil

function BuildShip(Type,Pos)
	local scale = gmod.GetGamemode().Scale
	if !Ships[Type] then
		print("Unknown Ship: "..Type)
		return false
	end
	local data = Ships[Type]
	if !data.Seat then 
		print("ERROR no seat for ship!!")
		return false
	end
	if table.Count(data)<1 then 
		print("ERROR creating ship!!!")
		return false
	end
	local s = ents.Create( "ent_ship" )
	s:SetPos(Pos)
	s:Spawn()
	s.SeatPos = data.Seat*scale
	s:SetNWVector("Seat",data.Seat*scale)
	if data.Base then
		s:SetModel(data.Base[1])
		if data.Base[2] then
			s:SetMaterial(data.Base[2])
		end
		if data.Base[3] then
			s:SetColor(data.Base[3])
		end
	end
	s:SetModelScale(scale)
	s:PhysicsInit(SOLID_VPHYSICS)
	s:SetMoveType(MOVETYPE_VPHYSICS)
	s:SetSolid(SOLID_VPHYSICS)
	s:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local phys = s:GetPhysicsObject()
	if phys:IsGravityEnabled() then
		phys:EnableGravity(false)
		phys:SetMass( 1000 )
	end

	for I=1,#data.Parts do
		--{"models/props_phx/construct/metal_plate2x4_tri.mdl",Vector(4,-62.5,-5),Angle(-0,-5.8,9)}
		local PD = data.Parts[I]
		local p = ents.Create( "prop_dynamic" )
		p:SetModel(PD[1])
		if string.find(PD[1],"thruster") then
			local startWidth,endWidth = 14,1
			util.SpriteTrail( p, 0, Color(255,255,255), 1, startWidth, endWidth, 4, 1 / ( startWidth + endWidth ) * 0.5 , "trails/laser.vmt" )

		end
		p:SetPos(s:LocalToWorld(PD[2]*scale))
		p:SetAngles(s:LocalToWorldAngles(PD[3]))
		if PD[4] then
			p:SetMaterial(PD[4])
		end
		if PD[5] then
			p:SetColor(PD[5])
		end
		if PD[6] then
			p:SetModelScale(PD[6]*scale)
		elseif scale!=1 then
			p:SetModelScale(scale)
		end

		p:SetParent(s)
		if !s.Parts then
			s.Parts = {}
		end
		s.Parts[I] = p
	end
	s.Data = data
	s:SetHealth(100)

	
	return s
end