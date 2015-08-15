
local Ship = {}
Ship.name = "Speedy"
Ship.DM = {5,12}
Ship.Cost = 50
Ship.HP = 100
Ship.Seat = Vector(16,0,3)
Ship.speed = {20,0}
Ship.acc = 0.2
Ship.Base = {"models/props_swamp/row_boat_ref.mdl","models/props_wasteland/wood_fence01a_skin2",Color(126,139,112)}

Ship.Parts = {}
-- Wings
Ship.Parts[1] = {"models/props_phx/construct/metal_plate2x4_tri.mdl",Vector(4,-62.5,-5),Angle(0,-5.8,9),"models/props_wasteland/wood_fence01a_skin2",Color(126,139,112)}
Ship.Parts[2] = {"models/props_phx/construct/metal_plate2x4_tri.mdl",Vector(4,62.5,-5),Angle(0,5.8,171),"models/props_wasteland/wood_fence01a_skin2",Color(126,139,112)}
Ship.Parts[3] = {"models/props_phx/construct/metal_plate1x2_tri.mdl",Vector(54, -82, 14),Angle(-0.3, -6, -44.8),"models/props_wasteland/wood_fence01a_skin2",Color(126,139,112)}
Ship.Parts[4] = {"models/props_phx/construct/metal_plate1x2_tri.mdl",Vector(54, 82, 14),Angle(-0.3, 6, 224.8),"models/props_wasteland/wood_fence01a_skin2",Color(126,139,112)}

-- Thruster
Ship.Parts[5] = {"models/maxofs2d/thruster_projector.mdl",Vector(105, 0, 0),Angle(90,0,0)}
Ship.Parts[6] = {"models/props_c17/furnitureboiler001a.mdl",Vector(70, 4, 2),Angle(-55.5, -90,90),nil,nil,0.8}

-- Solar Panel
Ship.Parts[7] = {"models/props_moonbase/moon_solarpanels01.mdl",Vector(44, 19,0),Angle(-84, 180,0),nil,nil,0.3}


AddShip(Ship.name,Ship)