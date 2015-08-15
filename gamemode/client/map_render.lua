
MapOBBMax = MapOBBMax or Vector(0,0,0)
MapOBBMin = MapOBBMin or Vector(0,0,0)
MapCenter = MapCenter or Vector(0,0,0)

SkyboxOBBMax = SkyboxOBBMax or Vector(0,0,0)
SkyboxOBBMin = SkyboxOBBMin or Vector(0,0,0)
SkyboxCenter = SkyboxCenter or Vector(0,0,0)
MapBoarder = MapBoarder or -1

--[[
game.GetWorld():SetNWVector("OBBMax",MapOBBMax)
game.GetWorld():SetNWVector("OBBMin",MapOBBMin)
game.GetWorld():SetNWVector("SkyOBBMax",SkyboxOBBMax)
game.GetWorld():SetNWVector("SkyOBBMin",SkyboxOBBMin)
game.GetWorld():SetNWVector("SkyboxCenter",SkyboxCenter)
game.GetWorld():SetNWVector("MapCenter",MapCenter)
	]]

surface.CreateFont( "WarningBIG", {
	font = "Arial",
	size = 80,
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

surface.CreateFont( "WarningMIDDLE", {
	font = "Arial",
	size = 40,
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

surface.CreateFont( "WarningSMALL", {
	font = "Arial",
	size = 30,
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




SkyboxCenter = SkyboxCenter or Vector(0,0,0)

-- Get the damn mapdata
timer.Create("RetrevingMapData", 1, 0, function()
	local e = game.GetWorld()
	if !e then return end

	MapOBBMax = e:GetNWVector("OBBMax",Vector(-1,0,0))
	MapOBBMin = e:GetNWVector("OBBMin",Vector(-1,0,0))

	SkyboxOBBMax = e:GetNWVector("SkyOBBMax",Vector(-1,0,0))
	SkyboxOBBMin = e:GetNWVector("SkyOBBMin",Vector(-1,0,0))

	SkyboxCenter = e:GetNWVector("SkyboxCenter",Vector(-1,0,0))
	MapCenter = e:GetNWVector("MapCenter",Vector(-1,0,0))
	MapBoarder = e:GetNWFloat("MapBoarder",-1)

	if MapOBBMax.x!=-1 and MapOBBMin.x != -1 and SkyboxCenter.x !=-1 and MapCenter.x!=1 and MapBoarder!=1 then
		print("Retreved mapdata ..")
		timer.Destroy("RetrevingMapData")
	end
end)



local Mat = Material("skies/floor.png", "noclamp")
local Mat2 = Material("skies/floor_invis.png", "noclamp mips smooth")

hook.Add("PostDrawTranslucentRenderables","DARF",function()
	
end)

hook.Add("PreDrawEffects","SkyRender",function()
	local scale = 20
	local width,height = MapOBBMax.x-MapOBBMin.x,MapOBBMax.y-MapOBBMin.y
	local t = (SysTime()/50)%10
	local tt = (SysTime()/175)%10
	local ttt = (SysTime()/215)%10

	cam.Start3D2D(Vector(MapOBBMin.x,MapOBBMin.y,MapCenter.z),Angle(0,90,0),1)
		surface.SetDrawColor(Color(255,255,255,255))		
		surface.SetMaterial(Mat)
		surface.DrawTexturedRectUV( 0,0,width,height,tt,tt/2,1+tt,1+tt/2 )

	cam.End3D2D()

	cam.Start3D2D(Vector(MapOBBMin.x,MapOBBMin.y,MapCenter.z+70),Angle(0,90,0),1)
		surface.SetDrawColor(Color(255,255,255,255))		
		surface.SetMaterial(Mat2)
		surface.DrawTexturedRectUV( 0,0,width,height,-t,t/3,-2-t,2+t/3 )
	cam.End3D2D()


	cam.Start3D2D(Vector(MapOBBMin.x,MapOBBMin.y,MapCenter.z+140),Angle(0,90,0),1)
		surface.SetDrawColor(Color(255,255,255,125))		
		surface.SetMaterial(Mat2)
		surface.DrawTexturedRectUV( 0,0,width,height,-t,t/3,-2-t,2+t/3 )
	cam.End3D2D()

	cam.Start3D2D(Vector(MapOBBMin.x,MapOBBMin.y,MapCenter.z+280),Angle(0,90,0),1)
		surface.SetDrawColor(Color(255,255,255,125))		
		surface.SetMaterial(Mat2)
		surface.DrawTexturedRectUV( 0,0,width,height,-tt,-ttt/3,-2-tt,-2-ttt/3 )
	cam.End3D2D()

	local Bases = ents.FindByClass("ent_baseship")
	for I=1,#Bases do
		local entz = Bases[I]
		if entz:GetNWFloat("Shield",0)>0 then
			render.SetMaterial(Mat2)
			local c = entz:GetColor()
			c.a = 155
			render.DrawSphere(entz:GetPos(),-2000,40,40,c)
		end
	end


	local Silos = ents.FindByClass("ent_missile")
	for I=1,#Silos do
		local entz = Silos[I]
		local me = GetMe()
		if entz:GetPos():Distance(me:GetPos())<500*2.5 then
			cam.Start3D2D(entz:GetPos(),Angle(0,90,0),5)
				surface.SetDrawColor(Color(155,155,155,205))		
				surface.SetMaterial(effectToMat("effects/circle2","UnlitGeneric",true))
				surface.DrawTexturedRectRotated(0,0,500,500,0)
			cam.End3D2D()
			cam.Start3D2D(Vector(entz:GetPos().x,entz:GetPos().y,me:GetPos().z-60),Angle(0,90,0),5)
				surface.SetDrawColor(Color(255,255,0,205))		
				surface.SetMaterial(effectToMat("effects/circle","UnlitGeneric",true))
				surface.DrawTexturedRectRotated(0,0,500,500,0)
			cam.End3D2D()
		elseif entz:GetPos():Distance(me:GetPos())<500*4 then
			cam.Start3D2D(Vector(entz:GetPos().x,entz:GetPos().y,me:GetPos().z-60),Angle(0,90,0),5)
				surface.SetDrawColor(Color(155,155,155,205))		
				surface.SetMaterial(effectToMat("effects/circle","UnlitGeneric",true))
				surface.DrawTexturedRectRotated(0,0,500,500,0)
			cam.End3D2D()
			cam.Start3D2D(entz:GetPos(),Angle(0,90,0),5)
				surface.SetDrawColor(Color(155,155,155,205))		
				surface.SetMaterial(effectToMat("effects/circle2","UnlitGeneric",true))
				surface.DrawTexturedRectRotated(0,0,500,500,0)
			cam.End3D2D()
		end
	end

	surface.SetDrawColor(Color(255,255,255,255))	
	if !MapBoarder then return end
	if !LocalPlayer() then return end
	local m = (1-MapBoarder)
	local max,min = Vector(MapOBBMax.x*m,MapOBBMax.y*m,MapOBBMax.z),Vector(MapOBBMin.x*m,MapOBBMin.y*m,MapCenter.z)
	if not LocalPlayer():GetPos():WithinAABox(max,min) then
		render.SetColorMaterial()
		render.DrawBox(Vector(0,0,0),Angle(0,0,0),min,max,Color(255,0,0,155),0)
	else

	end
end)

hook.Add("PostDrawOpaqueRenderables","SkyRender3",function()
	local width,height = SkyboxOBBMax.x-SkyboxOBBMin.x,SkyboxOBBMax.y-SkyboxOBBMin.y
	
	local tt = (SysTime()/175)%10
	local ttt = (SysTime()/215)%10
	local Scale = 7

	local t = (SysTime()/100)%10
	local tt = (SysTime()/175)%10
	local ttt = (SysTime()/215)%10



	cam.Start3D2D(SkyboxOBBMin+Vector(0,0,150),Angle(0,90,0),1)
		surface.SetDrawColor(Color(255,255,255,255))		
		surface.SetMaterial(Mat)
		surface.DrawTexturedRectUV( 0,0,width,height,tt,tt/2,(1*Scale)+tt,(1*Scale)+tt/2 )

	cam.End3D2D()

	cam.Start3D2D(SkyboxOBBMin+Vector(0,0,150+20),Angle(0,90,0),1)
		surface.SetDrawColor(Color(255,255,255,125))		
		surface.SetMaterial(Mat2)
		surface.DrawTexturedRectUV( 0,0,width,height,-t,t/3,-(2*Scale)-t,(2*Scale)+t/3 )
	cam.End3D2D()

	cam.Start3D2D(SkyboxOBBMin+Vector(0,0,150+40),Angle(0,90,0),1)
		surface.SetDrawColor(Color(255,255,255,125))		
		surface.SetMaterial(Mat2)
		surface.DrawTexturedRectUV( 0,0,width,height,-tt,-ttt/3,-(2*Scale)-tt,-(2*Scale)-ttt/3 )
	cam.End3D2D()

	cam.Start3D2D(SkyboxOBBMin+Vector(0,0,180),Angle(0,0,180),2)
		surface.SetDrawColor(Color(255,255,255,125))		
		surface.SetMaterial(Mat2)
		surface.DrawTexturedRectUV( 0,0,width,height,-tt,-ttt/3,-(2*Scale)-tt,-(2*Scale)-ttt/3 )
	cam.End3D2D()

end)

Render_Player_Outside = false

local MatAB = Material("vgui/alpha-back")
hook.Add("HUDPaint","BoarderWarning",function()
	local w,h = ScrW(),ScrH()
	if !MapBoarder then return end
	if !LocalPlayer() then return end
	if LocalPlayer():Team()<2 then return end
	local m = (1-MapBoarder)
	local max,min = Vector(MapOBBMax.x*m,MapOBBMax.y*m,MapOBBMax.z),Vector(MapOBBMin.x*m,MapOBBMin.y*m,MapCenter.z)

	if not GetMe():GetPos():WithinAABox(min,max) then
		surface.SetDrawColor(Color(255,55,55,245))
		local ws = 440
		local boxx,boxy = w/2-ws/2,h/3
		surface.SetMaterial(MatAB)
		local r = (SysTime()/4)%10
		local rr = math.abs(math.cos(SysTime()*3))*150

		surface.DrawTexturedRectUV(boxx,boxy,ws,100,r,2,r+3,1)
		
		surface.SetDrawColor(Color(0,0,0,105))
		surface.DrawRect(boxx+10,boxy+10,80,80)
		surface.SetDrawColor(Color(0,0,0,255))
		surface.DrawOutlinedRect(boxx,boxy,ws,100)

		surface.SetFont("WarningBIG")
		surface.SetTextColor(Color(255,255,255,105+rr))
		local TW,TH = surface.GetTextSize("!")
		surface.SetTextPos(boxx+50-TW/2,boxy+50-TH/2)
		surface.DrawText("!")

		surface.SetFont("WarningMIDDLE")
		local TW,TH = surface.GetTextSize("WARNING")
		surface.SetTextPos(boxx+ws/2-TW/2,boxy)
		surface.DrawText("WARNING")

		surface.SetFont("WarningSMALL")
		local s = "Outside boundary"
		local TW,TH2 = surface.GetTextSize(s)
		surface.SetTextPos(boxx+ws/2-TW/2,boxy+TH-8)
		surface.DrawText(s)
--		surface.DrawLine(boxx+34+TW,boxy+8,boxx+64+TW,boxy+88)
		Render_Player_Outside = true
	else
		Render_Player_Outside = false
	end
end)

hook.Add( "SetupWorldFog", "FoxController", function()
	render.FogMode( 1 ) 
	render.FogStart( 800 )
	render.FogEnd( 3000  )
	render.FogMaxDensity( 0.9 )

	local col = Vector(0.8,0.8,0.8)
	render.FogColor( col.x * 255, col.y * 255, col.z * 255 )

	return true
end )

hook.Add( "SetupSkyboxFog", "FoxController", function()
	render.FogMode( 1 ) 
	render.FogStart( 800 )
	render.FogEnd( 3000  )
	render.FogMaxDensity( 0.9 )

	local col = Vector(0.8,0.8,0.8)
	render.FogColor( col.x * 255, col.y * 255, col.z * 255 )

	return true
end )
--hook.Add( "SetupSkyboxFog", self, self.SetupSkyFog )