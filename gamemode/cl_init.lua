
include("shared.lua")
--DeriveGamemode("sandbox")
local ClientFiles	= file.Find(GM.FolderName .. "/gamemode/client/*.lua","LUA")

-- Materials .. because effects don't work
MatList = MatList or {}
function effectToMat(_str,_type,_alpha)
	if !_type then _type = "UnlitGeneric" end
	if type(MatList[_str.._type])!="IMaterial" then
		--create
		local params = {
			["$basetexture"] = _str,
			["$translucent"] = 1,
			["$vertexalpha"] = 1,
			["$vertexcolor"] = 1,
			["$nocull"] = 1

		}
		if _alpha then
			params["$additive"] = 1
		end
		MatList[_str.._type] = CreateMaterial("GM_CONVER".._str.._type,_type,params)
		return MatList[_str.._type]
	else
		return MatList[_str.._type]
	end
end	
function GetMe()
	if !LocalPlayer() then return end
	local ship = LocalPlayer():GetObserverTarget() or nil
	return ship or LocalPlayer()
end

-- Thx wiki
function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is need for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

MsgN('// Client Includes:')
for k, fl in pairs(ClientFiles) do
	MsgN('// Adding client include: '.. fl)
	include('client/' .. fl)
end
