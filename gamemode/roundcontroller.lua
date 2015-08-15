
function SendTeam(ply,n)
	print("Team",n)
	ply:SetTeam(n)
	if n<2 then
		ply:KillSilent()
		ply:Spawn()
	end
end

local InGame = false
local Winning = false

timer.Create("StartRound", 3, 0, function()
	local pl = player.GetAll()
	if #pl>3 and !InGame and !Winning then
		StartRound()
	elseif InGame then
		if RebleBase:Health()<1 then
			Winning = true
			InGame = false
			for I=1,#pl do
				pl[I]:PrintMessage(HUD_PRINTCENTER,"Combine wins!")
			end
			timer.Simple(6, function()
				StartRound()
			end)
		elseif CombineBase:Health()<1 then
			Winning = true
			InGame = false

			for I=1,#pl do
				pl[I]:PrintMessage(HUD_PRINTCENTER,"Rebles win!")
			end
			timer.Simple(6, function()
				StartRound()
			end)
		end
	end
end)

function GetSmallestTeam()
	local pl = player.GetAll()
	local Red,Blue = 0,0
	for I=1,#pl do
		if pl[I]:Team()==2 then
			Red = Red+1
		elseif pl[I]:Team()==3 then
			Blue = Blue+1
		end
	end
	if Red>Blue then
		return 3
	end
	if Blue>Red then
		return 2
	end
	return 0
end

concommand.Add( "join_team", function( ply,_,arg )
	local req = tonumber(arg[1])
	local n = GetSmallestTeam()
	if req <1 then
		req = n
	end
	if n == 0 or n == req then
		SendTeam(ply,req)
	end
	
end )

function GM:PlayerSpawn(ply)
	local n = ply:Team()
	if (ply.CanSpawn or 0)>=SysTime() or !InGame then 
		ply:KillSilent()
		return 
	end

	gmod.GetGamemode():PlayerSpawnAsSpectator( ply )
	ply:SetTeam(n)
	

	if n<2 or n>3 then return end
	local model = player_manager.TranslatePlayerModel( ply:GetInfo( "cl_playermodel" ) )
	print(model)
	if n==2 then
		local ship = BuildShip("Speedy",RebleBase:GetPos()+Vector(0,0,50))
		ply:SetPos(RebleBase:GetPos())

		ship.Driver = ply
		ply.Driving = ship
		ply:Spectate( OBS_MODE_CHASE )
	 	ply:SpectateEntity( ship, true )
	 	ply:StripWeapons()
	 	ship.Team = 2
	 	ship:SetNWFloat("Team",2)

	 	ship:SetNWEntity("Driver",ply)
	 	ship:SetNWString("DriverModel",model)
	elseif n==3 then
		local ship = BuildShip("Speedy",CombineBase:GetPos()+Vector(0,0,50))
		ply:SetPos(CombineBase:GetPos())
		
		ship.Driver = ply
		ply.Driving = ship
		ply:Spectate( OBS_MODE_CHASE )
	 	ply:SpectateEntity( ship, true )
	 	ply:StripWeapons()
	 	ship.Team = 3
	 	ship:SetNWFloat("Team",3)

	 	ship:SetNWEntity("Driver",ply)
	 	ship:SetNWString("DriverModel",model)
	end

end


function StartRound()
	RebleBase.Shield = 100
	RebleBase:SetHealth(100)
	RebleBase:SetNWFloat("Shield",100)

	CombineBase.Shield = 100
	CombineBase:SetHealth(100)
	CombineBase:SetNWFloat("Shield",100)

	local entz = ents.FindByClass("ent_ship")
		table.Add(entz,ents.FindByClass("ent_hitmissile"))
	for I=1,#entz do
		SafeRemoveEntity(entz[I])
	end

	local pl = player.GetAll()
	InGame = true
	Winning = false
	for I=1,#pl do
		local ply = pl[I]
		ply:SetFrags(0)
		ply:SetDeaths(0)
		local team = ply:Team()
		if team<2 or team>3 then
			team = GetSmallestTeam()
			if team<1 then team = math.random(2,3) end
			SendTeam(ply,team)
		end
		ply:Spawn()
	end

end

function GM:PlayerInitialSpawn( ply )
    ply:SetTeam( 1 )
end

function GM:PlayerLoadout( ply )
	-- Clear 
end

function PIS(ply)
       ply:SetTeam(1)
end
hook.Add("PlayerInitialSpawn", "SetFirst", PIS)