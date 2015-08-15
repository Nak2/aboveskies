
MapOBBMax = Vector(0,0,0)
MapOBBMin = Vector(0,0,0)
MapCenter = Vector(0,0,-10390)
MapBoarder = 0.1

SkyboxOBBMax = SkyboxOBBMax or Vector(0,0,0)
SkyboxOBBMin = SkyboxOBBMin or Vector(0,0,0)
SkyboxCenter = SkyboxCenter or Vector(0,0,0)

ScanMap = function()
	local Cam = ents.FindByClass("sky_camera")
	local SkyBoxCenter = Vector(0,0,0)
	if #Cam>0 then
		SkyboxCenter = Cam[1]:GetPos()
		print(SkyboxCenter)
	end

	local ETrace = function(_start,_end)
		local tr = util.TraceLine( {
			start = _start,
			endpos = _end,
			filter = game.GetWorld()
		} )
		return tr.HitPos or _end
	end

	-- Locate the top of the map
	local zEnd = 0
	local z = 0
	for I=1,100 do
		local tr = util.TraceLine( {
			start = Vector(0,0,z),
			endpos = Vector(0,0,z+100000),
			filter = game.GetWorld()
		} )
		if tr.HitSky then
			zEnd = tr.HitPos.z
			break
		elseif tr.Hit then
			z = ((tr.HitPos)+Vector(0,0,10)).z
		end
	end
	if zEnd<1 then
		print("[ERROR] Couldn't detect map size. [z = "..zEnd.."]") 
		return 
	end

	zStart = ETrace(Vector(0,0,0),Vector(0,0,-100000)).z

	xStart = ETrace(Vector(0,0,zEnd-10),Vector(-100000,0,zEnd-10)).x
	yStart = ETrace(Vector(0,0,zEnd-10),Vector(0,-100000,zEnd-10)).y
	xEnd = ETrace(Vector(0,0,zEnd-10),Vector(100000,0,zEnd-10)).x
	yEnd = ETrace(Vector(0,0,zEnd-10),Vector(0,100000,zEnd-10)).y

	MapOBBMax = Vector(xEnd,yEnd,zEnd)
	MapOBBMin = Vector(xStart,yStart,zStart)

	print("MapSize: ["..xStart..","..yStart..","..zStart.."]","["..xEnd..","..yEnd..","..zEnd.."]")

	zEnd = ETrace(SkyboxCenter,SkyboxCenter+Vector(0,0,1000)).z
	zStart = ETrace(SkyboxCenter,SkyboxCenter+Vector(0,0,-1000)).z
	xStart = ETrace(SkyboxCenter,SkyboxCenter+Vector(-10000,0,0)).x
	yStart = ETrace(SkyboxCenter,SkyboxCenter+Vector(0,-10000,0)).y

	xEnd = ETrace(SkyboxCenter,SkyboxCenter+Vector(10000,0,0)).x
	yEnd = ETrace(SkyboxCenter,SkyboxCenter+Vector(0,10000,0)).y

	SkyboxOBBMax = Vector(xEnd,yEnd,zEnd)
	SkyboxOBBMin = Vector(xStart,yStart,zStart)

	game.GetWorld():SetNWVector("OBBMax",MapOBBMax)
	game.GetWorld():SetNWVector("OBBMin",MapOBBMin)
	game.GetWorld():SetNWVector("SkyOBBMax",SkyboxOBBMax)
	game.GetWorld():SetNWVector("SkyOBBMin",SkyboxOBBMin)
	game.GetWorld():SetNWVector("SkyboxCenter",SkyboxCenter)
	game.GetWorld():SetNWVector("MapCenter",MapCenter)
	game.GetWorld():SetNWVector("MapBoarder",MapBoarder)

	hook.Call("MapScanComplete")
end
hook.Add( "InitPostEntity", "MapScan", ScanMap)
if DEBUGLOADED then
	timer.Simple(0.1, function()
		ScanMap()
	end)
end