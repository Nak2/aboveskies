
GM.Name 	= "Air Battle"
GM.Version = "0.1"
GM.Author 	= "Nak"

GM.Scale = 0.4 -- The smaller .. the bigger map
GM.Scale = math.Clamp(GM.Scale,0.16,1)
-- Debug
local RemoveTable = {}
function SuperSafeRemoveEntity(ent) -- Because removing one in a render function crashes everything
	RemoveTable[ent] = true
end
hook.Add("Think","NaksSuperFixForEntitieRemoval",function()
	for k, v in pairs( RemoveTable ) do
		k:Remove()
		RemoveTable[k] = nil
	end
end)

local SharedFiles	= file.Find(GM.FolderName .. "/gamemode/shared/*.lua","LUA")
MsgN('// Shared Includes:')
for k, fl in pairs(SharedFiles) do
	MsgN('// Sharing file: '.. fl)
	if SERVER then
		AddCSLuaFile('shared/' .. fl)
	end
	include('shared/' .. fl)
end