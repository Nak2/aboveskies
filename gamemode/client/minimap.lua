
local Point = Material("vgui/blog_back")

local MinimapScale = 0.015 -- Everythings scale on the minimap
local MMx,MMy = 1,1 	-- Minimap Max X, Minimap Max Y
local MPx,MPy = 1,10 -- Minimap Pos X, Minimap Pos Y (Always 10)
local MCx,MCy = 1,1

local BigMap = false
local Down = false

local cos = math.cos
local sin = math.sin
local rad = math.rad

--[[
if !Down and input.IsKeyDown( KEY_M ) then
	Down = true
	BigMap = !BigMap
elseif Down and !input.IsKeyDown( KEY_M ) then
	Down = false
end]]

surface.CreateFont( "SiloNumber", {
	font = "Arial",
	size = 20,
	weight = 1500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local radarborder = Material("skies/radar.png","noclamp smooth")
local shipmat = Material("skies/ship.png","noclamp smooth")
local silomat = Material("skies/missile.png","noclamp smooth")

local function PosToMapPos(x,y,ignoreZ)
	if type(x)=="Entity" then
		local p = x:GetPos()
		x = p.x
		y = p.y
	end
	local pos = GetMe():GetPos()
	local yaw = -(Vector(x,y,pos.z)-pos):Angle().yaw-90+EyeAngles().yaw
	local dis = pos:Distance(Vector(x,y,pos.z))*MinimapScale

	if ignoreZ then
		dis = math.min(dis,100)
	end
	local xx = cos(rad(yaw))*dis + (ScrW()-135)
	local yy = sin(rad(yaw))*dis + (135)

	return xx,yy,yaw
end

local function RenderObjects(w,h)
	local Bases = ents.FindByClass("ent_missile")
	surface.SetMaterial(silomat)
	local me = GetMe()
	for I=1,#Bases do
		local ent = Bases[I]
		local x,y,yaw = PosToMapPos(ent,nil,true)
		surface.SetFont("SiloNumber")
		local Team = ent:GetNWFloat("Team",0)
		surface.SetTextPos(x-4,y-10)
		surface.SetTextColor(Color(0,0,0,205))
		if Team==2 then
			surface.SetDrawColor(Color(255,0,0,255))
		elseif Team == 3 then
			surface.SetDrawColor(Color(0,0,255,255))
		else
			surface.SetDrawColor(Color(155,155,155,255))
		end
		surface.DrawTexturedRectRotated(x,y,26,26,0)
		surface.DrawText(I)
	end

	local Ships = ents.FindByClass("ent_ship")
	surface.SetMaterial(shipmat)
	for I=1,#Ships do
		local ent = Ships[I]
		local team = ent:GetNWFloat("Team",0)
		if me!=ent and (me:GetPos():Distance(ent:GetPos())<4000 or LocalPlayer():Team()==team) then
			local x,y,yaw = PosToMapPos(ent,nil)
			if team==2 then
				surface.SetDrawColor(Color(255,0,0,255))
			elseif team == 3 then
				surface.SetDrawColor(Color(0,0,255,255))
			else
				surface.SetDrawColor(Color(155,155,155,255))
			end
			surface.DrawTexturedRectRotated(x,y,16,16,ent:GetAngles().yaw-EyeAngles().yaw+180)
		end
		
	end


	local ent = GetMe()
	local x,y,yaw = PosToMapPos(ent)


	surface.SetDrawColor(Color(255,255,255))
	if LocalPlayer():Team()==2 then
		surface.SetDrawColor(Color(255,0,0))
	elseif LocalPlayer():Team()==3 then
		surface.SetDrawColor(Color(0,0,255))
	end
	
	surface.SetMaterial(shipmat)
	
	surface.DrawTexturedRectRotated(x,y,20,20,ent:GetAngles().yaw-EyeAngles().yaw+180)
	surface.SetDrawColor(Color(155,155,155,155))
	surface.DrawTexturedRectRotated(x,y,16,16,ent:GetAngles().yaw-EyeAngles().yaw+180)


	
end

function UpdateVars()
	if MinimapScale<0 and MapBoarder>0 then
		MMx,MMy = (MapOBBMax.x-MapOBBMin.x),(MapOBBMax.y-MapOBBMin.y)
		local Biggest = math.max(MMx,MMy)
			MinimapScale = 300/Biggest
		MMx = MMx*MinimapScale
		MMy = MMy*MinimapScale

		MCx = -MapOBBMin.x*MinimapScale
		MCy = -MapOBBMin.y*MinimapScale
		MPx = ScrW()-MMx-10
	end
end

local Mat = Material("skies/floor.png", "noclamp")
local Mat2 = Material("skies/floor_invis.png", "noclamp mips smooth")

function DrawMap(w,h)
	-- Setup vars (Onetime use since its map)
		UpdateVars()
	local t = (SysTime()/50)%10
	local tt = 0--(SysTime()/55)%10

	local me = GetMe()
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	
	local m = Matrix()
	local y = EyeAngles().yaw
	m:SetAngles( Angle( 0, y, 0 ) )
	local xx = -cos(rad(y))*125-cos(rad(y+90))*125
	local yy = -sin(rad(y))*125-sin(rad(y+90))*125

	local pos = me:GetPos()
	V = -pos.x*MinimapScale/250%1
	U = -pos.y*MinimapScale/250%1



	m:SetTranslation( Vector( w-135+xx,135+yy, 0 ) )
	cam.PushModelMatrix( m )
		surface.SetDrawColor(Color(255,255,255))
		surface.SetMaterial(Mat)
		surface.DrawTexturedRectUV(0,0,250,250,tt+U,tt/2+V,1+tt+U,1+tt/2+V )
	cam.PopModelMatrix()
	render.PopFilterMag()
	render.PopFilterMin()

	surface.SetDrawColor(Color(255,255,255,60))
	surface.SetMaterial(Material("color"))
	draw.Circle(w-135,10+125,4000*MinimapScale,20)
	--
end



hook.Add("HUDPaint","MiniMap",function()

	local w,h = ScrW(),ScrH()
	if !MapBoarder then return end
	if !LocalPlayer() then return end

	render.ClearStencil()
	render.ClearStencil();
	render.SetStencilEnable( true );
	render.SetStencilCompareFunction( STENCIL_ALWAYS );
	render.SetStencilPassOperation( STENCIL_REPLACE );
	render.SetStencilFailOperation( STENCIL_KEEP );
	render.SetStencilZFailOperation( STENCIL_KEEP );
	render.SetStencilWriteMask( 1 );
	render.SetStencilTestMask( 1 );
	render.SetStencilReferenceValue( 1 );
	-- Mask
	surface.SetDrawColor(Color(255,255,255,1))
	draw.Circle(w-135,10+125,112,20)

	render.SetStencilCompareFunction( STENCIL_EQUAL );
	
	-- Render

	--[[	-- Messes up the view
	local CamData = {}
	CamData.angles = Angle(90,0,0)
	CamData.origin = GetMe():GetPos()+Vector(0,0,4000)
	CamData.x = w-260
	CamData.y = 10
	CamData.w = 250
	CamData.h = 250
	render.RenderView( CamData ) ]]

	DrawMap(w,h)

	RenderObjects(w,h)

	render.SetStencilEnable( false )

	local me = GetMe()
	local hp = me:Health()
	surface.SetDrawColor(Color(0,0,0))
	surface.DrawRect(100,h-50,200,20)
	surface.SetDrawColor(Color(0,255,0))
	surface.DrawRect(100,h-50,2*hp,20)

	
	surface.SetMaterial(radarborder)
	surface.SetDrawColor(Color(255,255,255,255))
	surface.DrawTexturedRect(w-260,10,250,250)


end)


--[[

function UpdateVars()
	if MinimapScale<0 and MapBoarder>0 then
		MMx,MMy = (MapOBBMax.x-MapOBBMin.x),(MapOBBMax.y-MapOBBMin.y)
		local Biggest = math.max(MMx,MMy)
			MinimapScale = 300/Biggest
		MMx = MMx*MinimapScale
		MMy = MMy*MinimapScale

		MCx = -MapOBBMin.x*MinimapScale
		MCy = -MapOBBMin.y*MinimapScale
		MPx = ScrW()-MMx-10
	end
end

local function PosToMinimap(x,y)
	if type(x)=="Entity"|| type(x)=="Player" then
		local p = x:GetPos()
		local s = x:OBBCenter()
		x = p.x + s.x
		y = p.y + s.y
	end
	return {
		x = (x*MinimapScale)+MPx+MCx,
		y = (y*MinimapScale)+MPy+MCy}
end

local mats = {}
	mats[1] = Material("sprites/minimap_icons/spec_camera")
	mats[2] = Material("sprites/minimap_icons/blue_player")
	mats[3] = Material("sprites/minimap_icons/red_player")


function DrawObjects()
	if !LocalPlayer() then return end

	--
	local Bases = ents.FindByClass("ent_baseship")
	for I=1,#Bases do
		local entz = Bases[I]
		local pos = PosToMinimap(entz)
		if entz:GetNWFloat("Shield",0)>0 then
			surface.SetMaterial(effectToMat("effects/circle_altered","UnlitGeneric",true))
			surface.SetDrawColor(Color(155,155,255,205))
			surface.DrawTexturedRectRotated(pos.x,pos.y,40,40,SysTime()*10%360+(I*90))
			surface.DrawTexturedRectRotated(pos.x,pos.y,40,40,SysTime()*-21%360+(I*155))
		end
		surface.SetMaterial(effectToMat("effects/circle2","UnlitGeneric",true))
		surface.SetDrawColor(entz:GetColor())
		surface.DrawTexturedRect(pos.x-8,pos.y-8,16,16)
	end

	local Silos = ents.FindByClass("ent_missile")
	for I=1,#Silos do
		local entz = Silos[I]
		local pos = PosToMinimap(entz)

		surface.SetMaterial(effectToMat("effects/circle2","UnlitGeneric",true))
		surface.SetDrawColor(Color(255,255,255,105))
		surface.DrawTexturedRect(pos.x-8,pos.y-8,16,16)
	end


	local Shipz = ents.FindByClass("ent_ship")
	for I=1,#Shipz do
		local entz = Shipz[I]
		local pos = PosToMinimap(entz)
		local ply = entz:GetNWEntity("Driver")
		local Mat = mats[1]
		if type(ply)!="Player" then
			surface.SetDrawColor(Color(255,255,255,255))
		else
			if ply!=LocalPlayer() then
				Mat =  mats[ply:Team()+1]
			end
		end

		surface.SetMaterial(mats[2])
		
		surface.DrawTexturedRectRotated(pos.x,pos.y,16,16,entz:GetAngles().yaw)
	end

	surface.SetDrawColor(Color(255,255,255))
	surface.SetMaterial(Point)

	--[[
	local pos = PosToMinimap(LocalPlayer())
	surface.SetTextPos(10,100)
	surface.DrawText("Posx: "..pos.x)
	surface.DrawTexturedRectRotated(pos.x,pos.y,16,16,-LocalPlayer():GetAngles().yaw+180)
	]]
--[[	
end
local MatAB = Material("vgui/alpha-back")
local function DrawGrit(x,y,w,h)
	


	local st_x = x+w*MapBoarder/2
	local st_y = y+h*MapBoarder/2

	local st_w = w*(1-MapBoarder)
	local st_h = h*(1-MapBoarder)

	surface.SetDrawColor(Color(0,0,0,245))
	surface.DrawRect(x,y,w,h)

	if Render_Player_Outside then
		surface.SetDrawColor(Color(255,0,0,75+55*math.cos(SysTime()*4)))
		surface.SetMaterial(MatAB)
		surface.DrawTexturedRectUV(x,y,w,h,6,0,8,1)
	end
	surface.SetDrawColor(Color(173,255,47,55))
	surface.DrawOutlinedRect(st_x,st_y,st_w,st_h)
	for I=1,13 do
		local yy = st_h/14*I
		surface.DrawLine(st_x,st_y+yy,st_x+st_w,st_y+yy)
	end

	for I=1,9 do
		local xx = st_h/10*I
		surface.DrawLine(st_x+xx,st_y,st_x+xx,st_y+st_h)
	end
	--MapBoarder
end

local MatAB = Material("vgui/alpha-back")
hook.Add("HUDPaint","MiniMap",function()
	local w,h = ScrW(),ScrH()
	if !MapBoarder then return end
	if !LocalPlayer() then return end

	-- Setup-vars once .. unless its a dynamic map (Joking .. this is Source we're talking about)
		UpdateVars()
	
	local s = 150
	--MapOBBMax
	--MapOBBMin
	local x = LocalPlayer():GetPos().x
	local y = LocalPlayer():GetPos().y

	DrawGrit(MPx,MPy,MMx,MMy)

	DrawObjects()
end)

]]