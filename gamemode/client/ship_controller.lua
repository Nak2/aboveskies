
-- Spectating don't allow A or D .. this is a fix
hook.Add("CreateMove","FixMove",function(cmd)
	if input.IsKeyDown(KEY_A) then
		cmd:SetButtons(cmd:GetButtons() + IN_LEFT)
	end
	if input.IsKeyDown(KEY_D) then
		cmd:SetButtons(cmd:GetButtons() + IN_RIGHT)
	end
end)

local function ViewFix(ply, pos, angles, fov)
	if !LocalPlayer() then return end
	local ent = LocalPlayer():GetObserverTarget( )

	if !ent and (LocalPlayer():Team()<2 or LocalPlayer():Team()>3) then 
		local Yaw = (SysTime()*3)%360
		local view = {}
		view.origin = MapCenter-Angle(35,Yaw,0):Forward()*1000
		view.angles = Angle(0,Yaw,0)
		return view
	end
	if !ent then return end
	if !ent:IsValid() then return end
	if ent:GetClass()!="ent_ship" then return end

	
	local ang = EyeAngles()
	local pos = ent:GetPos()+ang:Up()*10
	local dist = 100

	local trace = {};
		trace.start = pos;
		trace.endpos = pos - ( ang:Forward() * dist );
		trace.mask = MASK_SOLID_BRUSHONLY

	local trace = util.TraceLine( trace );
	if( trace.HitPos:Distance( pos ) < dist - 10 ) then
		dist = trace.HitPos:Distance( pos ) - 10;
	end;

	local view = {}

	view.origin = pos+ang:Forward()*-dist

	angles.r = 0
    view.angles = angles
    view.fov = 90--math.min(20,ent:GetVelocity():Length())
    return view
end
hook.Add("CalcView", "ViewFix", ViewFix)