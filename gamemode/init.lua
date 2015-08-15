AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

MsgN("Loading: "..GM.Name.." Version: "..GM.Version)

GM.Debug = false
--DeriveGamemode("sandbox")

local ClientFiles	= file.Find(GM.FolderName .. "/gamemode/client/*.lua","LUA")
local ServerFiles	= file.Find(GM.FolderName .. "/gamemode/server/*.lua","LUA")

GameTree = {}

MsgN('// Client Includes:')
for k, fl in pairs(ClientFiles) do
	MsgN('// Adding client include: '.. fl)
	AddCSLuaFile('client/' .. fl)
end

MsgN('// Server Includes:')
for k, fl in pairs(ServerFiles) do
	MsgN('// Including file: '.. fl)
	include('server/' .. fl)
end

local str = [[
    // | |                     //   ) )                                            
   //__| |    ( )  __         //___/ /   ___    __  ___ __  ___ //  ___      ___   
  / ___  |   / / //  ) )     / __  (   //   ) )  / /     / /   // //___) ) ((   ) )
 //    | |  / / //          //    ) ) //   / /  / /     / /   // //         \ \    
//     | | / / //          //____/ / ((___( (  / /     / /   // ((____   //   ) )  

By Nak

This work is licensed under a Creative Commons Attribution 4.0 International License.]]
print(str)
print("Loading round ..")
include("roundcontroller.lua")

DEBUGLOADED = DEBUGLOADED or false
hook.Add( "InitPostEntity", "DEBUGLOADED", function()
	DEBUGLOADED = true
end)

-- Thx wiki for a lazy script for everything
local ContentFolder = "gamemodes/"..GM.FolderName .. "/content"
local I = 0
function AddDir(dir)
	if not file.Exists(dir,"GAME") then print("Can't find "..dir) return 0 end

	local files,dirs = file.Find(dir.."/*","GAME")

	for _, fdir in pairs(dirs) do
		if fdir != ".svn" then -- Don't spam people with useless .svn folders
			AddDir(dir.."/"..fdir)
		end
	end
 
	for k,v in pairs(files) do
		local f = string.sub(dir.."/"..v,string.len(ContentFolder)+2)
		resource.AddSingleFile(f)
		I = I+1
	end
end
AddDir(ContentFolder)
print("Added "..I.." content files from "..ContentFolder)