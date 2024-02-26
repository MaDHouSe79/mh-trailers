--[[ ===================================================== ]] --
--[[             MH Trailers Script by MaDHouSe            ]] --
--[[ ===================================================== ]] --

Config.AttachedKey = 38     -- 38 = E
Config.AttacheKeyTxt = "E"  -- if AttachedKey = 38 this is E

Config.Models = {
    trucks = {'hauler', 'bison', 'sadler'},
    trailers = {'tr2', 'trailersmall', 'boattrailer', 'trflat', 'pjtrailer'},
    ramp = "imp_prop_flatbed_ramp"
}

-- menu vehicle check
-- this vehicles can use the selected trailers.
Config.AllowToMerge = {
    ['hauler'] = {
        ['tr2'] = true,
        ['trflat'] = true,
        ['pjtrailer'] = true
    },
    ['bison'] = {
        ['trailersmall'] = true,
        ['boattrailer'] = true,
    },
    ['sadler'] = {
        ['trailersmall'] = true,
        ['boattrailer'] = true,
    },
}

-- trailer offset spawn position
Config.Offsets = {
    ['tr2'] = {
        ['hauler'] = 7.0,
    },
    ['trflat'] = {
        ['hauler'] = 7.0,
    },
    ['boattrailer'] = {
        ['bison'] = 7.0,
        ['sadler'] = 7.0,
    },
    ['trailersmall'] = {
        ['bison'] = 6.0,
        ['sadler'] = 6.0,
    },
}

-- Trailer rent shop
Config.Rent = {
    shop = {
        ped      = "S_M_M_TRUCKER_01",
        senario  = "WORLD_HUMAN_STAND_MOBILE",
        location = vector4(1108.8704, -2256.7051, 30.9380, 95.5586),
        cost     = 500
    },
    spawn = {
        truck   = vector3(1103.74, -2244.24, 30.52),
        trailer = vector3(1104.49, -2236.33, 30.32),
        garage  = vector3(1114.6820, -2285.8853, 30.4499),
        heading = 175.35,
    },
    blip = {
        garagelabel = "Trailer Rent Garage",
        shoplabel   = "Trailer Rent Shop",
        sprite      = 479,
        color       = 5,
        scale       = 0.5,
    }
}

-- ignore this vehicle hash to attach a trailer
Config.IgnoreVehicle = {
    [1377619001] = true,  -- man truck
    [2078290630] = true,  -- tr2 trailer
    [1029869057] = true,  -- pjtrailer
    [-1352468814] = true, -- trflat
    [712162987] = true,   -- small trailer
    [524108981] = true,   -- boat trailer
    [-901038522] = true,  -- ramp
}

Config.TrailerSettings = {
    -- tr2 trailer
    [2078290630] = {
        offsetX = 0.0,   -- dont edit this part
        offsetY = 0.0,   -- dont edit this part
        offsetZ = 0.08,  -- dont edit this part
        hasRamp = false, -- if this trailer has a ramp already
        hasdoors = true, -- if this trailer has doors (this can be ramps as well, depends on the door numver)
        width = 3.0,     -- the width of the trailer 
        length = 9.0,    -- the length of the trailer
        loffset = -1.0,  -- lower offset (dont edit this part)
        doors = {ramp = 5, platform = 4}, -- door numbers (make sure this is right)
        ramp = {},       -- this trailer has its own ramp
        maxspace = 6,    -- max space for vehicles
        parked = 0,      -- count the total parked vehicles on this trailer.
    },

    -- pjtrailer (gooseneck)
    [1029869057]  = {
        offsetX = 0.0,
        offsetY = 0.0,
        offsetZ = 0.08,
        width = 3.0,
        length = 9.0,
        loffset = -1.0,
        hasRamp = false,
        hasdoors = true,
        doors = {ramp = 5, platform = 4},
        ramp = {},
        maxspace = 2,
        parked = 0,
    }, 

    -- trflat (only a ramp)
    [-1352468814] = {
        offsetX = 0.0,
        offsetY = 0.0,
        offsetZ = 0.15,
        width = 3.0,
        length = 9.0,
        loffset = -1.0,
        hasRamp = true,
        hasdoors = false,
        doors = {ramp = 5},
        ramp = {offsetX = 0.0, offsetY = -9.3, offsetZ = -1.4, rotation = 180.0},
        maxspace = 2,
        parked = 0,
    },      

    -- small trailer (no doords)
    [712162987] = {
        offsetX = 0.0,
        offsetY = -0.3,
        offsetZ = 0.08,
        width = 3.0,
        length = 9.0,
        loffset = -1.0,
        hasdoors = false,
        hasRamp = false,
        doors = {},
        ramp = {},
        maxspace = 1,
        parked = 0,
    },

    -- boat trailer (no doors)
    [524108981] = {
        offsetX = 0.0,
        offsetY = 0.0,
        offsetZ = 0.08,
        width = 3.0,
        length = 9.0,
        loffset = -1.0,
        hasdoors = false,
        hasRamp = false,
        doors = {},
        ramp = {},
        maxspace = 1,
        parked = 0,
    },                                   
}

-- just for debugging
Config.DebugTrailers = false
Config.DebugDoor = false
Config.DebugPlatform = false
Config.DebugRamp = false
