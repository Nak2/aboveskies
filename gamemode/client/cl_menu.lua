
local MatAB = Material("vgui/alpha-back")
local function DrawBackground(w,h)
	surface.SetDrawColor(Color(255,255,0,155))
	surface.SetMaterial(MatAB)
	surface.DrawTexturedRectUV(0,0,w,50,0,0,w/120,1)
end

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

local Res = Material("skies/resistance.png","noclamp smooth")
local Com = Material("skies/combine.png","noclamp smooth")

local Ran = Material("vgui/class_sel_sm_random_inactive")


function RemoveMenu()
	SelectScreen:Remove()
	SelectScreen = nil
end

function CreateVGUI(w,h)
	if type(SelectScreen)!="nil" then return end
	local s = vgui.Create("DPanel")
	local ww,hh = 250*2+16,250*2
	s:SetPos(w/2-ww/2,h/2-hh/2)
	s:SetSize(ww,hh)
	s:MakePopup()
	function s:Paint()
		local w,h = self:GetSize()
		surface.SetDrawColor(Color(255,255,255,0))
		surface.DrawRect(0,0,w,h)
	end

	local ran = vgui.Create("DButton",s)
	ran:SetPos(ww/2-250/2,100)
	ran:SetSize(250,250*2)
	ran:SetText("")
	function ran:Paint()
		local w,h = self:GetSize()
		surface.SetMaterial(Ran)
		if self:IsHovered() then
			surface.SetDrawColor(Color(205,205,205,255))
			surface.DrawTexturedRect(0,0,w,h)
			surface.DrawTexturedRect(0,0,w,h)
		else
			surface.SetDrawColor(Color(205,205,205,205))
		end
		surface.DrawTexturedRect(0,0,w,h)
	end
	ran.DoClick = function()
		RunConsoleCommand("join_team","0")
		s:Remove()
	end

	local reb = vgui.Create("DButton",s)
	reb:SetPos(0,0)
	reb:SetSize(250,250)
	reb:SetText("")
	function reb:Paint()
		local w,h = self:GetSize()
		if self:IsHovered() then
			surface.SetDrawColor(Color(205,0,0,255))
		else
			surface.SetDrawColor(Color(155,0,0,205))
		end
		surface.SetMaterial(Res)
		surface.DrawTexturedRect(0,0,w,h)
	end

	reb.DoClick = function()
		RunConsoleCommand("join_team","2")
		s:Remove()
	end

	local com = vgui.Create("DButton",s)
	com:SetPos(250+16,0)
	com:SetSize(250,250)
	com:SetText("")
	function com:Paint()
		local w,h = self:GetSize()
		if self:IsHovered() then
			surface.SetDrawColor(Color(0,0,205,255))
		else
			surface.SetDrawColor(Color(0,0,155,205))
		end
		surface.SetMaterial(Com)
		surface.DrawTexturedRect(0,0,w,h)
	end

	com.DoClick = function()
		RunConsoleCommand("join_team","3")
		s:Remove()
	end

	SelectScreen = s
end

local cos = math.cos
local silomat = Material("skies/missile.png","noclamp smooth")
hook.Add("HUDPaint","MenuRender",function()
	local w,h = ScrW(),ScrH()
	if !LocalPlayer() then return end
	if LocalPlayer():Team()<2 or LocalPlayer():Team()>3 then
		DrawBackground(w,h)
		CreateVGUI(w,h)

		local MX,MY = gui.MouseX(),gui.MouseY()
	else
		local Mis = ents.FindByClass("ent_missile")
		surface.SetMaterial(silomat)
		for I=1,#Mis do
			local t = Mis[I]:GetNWFloat("Team",0)
			local c = Mis[I]:GetNWFloat("CapPower",0)
			local ti = (cos(SysTime()*5)+1)/2*c
			local x = -#Mis*25+(I*50)

			local p = Mis[I]:GetNWFloat("Power",0.4)

			surface.SetDrawColor(Color(0,0,0))
			surface.DrawTexturedRectUV(w/2+x-4,10-4+(52*(1-p)),52,52*p,0,1-p,1,1)

			if t<2 then
				surface.SetDrawColor(Color(155+100*ti,155+100*ti,155+100*ti,255))
			elseif t==2 then
				surface.SetDrawColor(Color(255,0,0,255))
			elseif t == 3 then
				surface.SetDrawColor(Color(0,0,255,255))
			end
			
			surface.DrawTexturedRect(w/2+x,10,44,44)
			surface.SetFont("WarningSMALL")
			surface.SetTextPos(w/2+x+14,20)
			surface.SetTextColor(Color(0,0,0))
			surface.DrawText(I)
		end

		local Base = ents.FindByClass("ent_baseship")
		if #Base>1 then
			local S,H = Base[1]:GetNWFloat("Shield",0),Base[1]:Health()

			surface.SetMaterial(Res)
			surface.SetDrawColor(Base[1]:GetColor())
			surface.DrawTexturedRect(w/2-#Mis*25-52/2,34-52/2,52,52)

			surface.SetMaterial(effectToMat("effects/circle4","UnlitGeneric",true))
			surface.SetDrawColor(Color(155,155,255,255*S))
			surface.DrawTexturedRectUV(w/2-#Mis*25-90/2,34-90/2,90,90,0,0,1,1)

			local S,H = Base[2]:GetNWFloat("Shield",0),Base[2]:Health()
			surface.SetDrawColor(Base[2]:GetColor())
			surface.SetMaterial(Com)
			surface.DrawTexturedRect(w/2+#Mis*25+52/2+30,34-52/2,52,52)

			surface.SetMaterial(effectToMat("effects/circle4","UnlitGeneric",true))
			surface.SetDrawColor(Color(155,155,255,255*S))
			surface.DrawTexturedRectUV(w/2+#Mis*25+90/2-2,38-90/2,90,90,0,0,1,1)
		end
	end
end)