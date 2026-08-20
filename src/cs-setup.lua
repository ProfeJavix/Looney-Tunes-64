local LOONEY_TUNES_64 = get_active_mod().name
local defaultLifeIcon = get_texture_info("exclamation-icon")

---@param data LTData
---@return integer
local function addLooneyTunesChar(data)
    local ct = _G.charSelect.character_add(
        data.name,                        -- Character Name
        data.description,                 -- Description
        data.author,                      -- Credits
        data.menuColor,                   -- Menu Color
        data.model,                       -- Character Model
        data.charType or CT_MARIO,        -- Override Character
        data.lifeIcon or defaultLifeIcon, -- Life Icon
        data.camScale or 1                -- Camera Scale
    )

    _G.charSelect.character_add_caps(
        data.model,
        {
            normal = smlua_model_util_get_id(data.id .. "_cap_base_geo"),
            wing = smlua_model_util_get_id(data.id .. "_cap_wing_geo"),
            metal = smlua_model_util_get_id(data.id .. "_cap_metal_geo")
        }
    )

    for _, paletteData in ipairs(data.palettes or {}) do
        _G.charSelect.character_add_palette_preset(data.model, paletteData.palette, paletteData.name)
    end

    if data.animData then
        _G.charSelect.character_add_animations(data.model, data.animData.animTable, data.animData.eyeTable,
            data.animData.handTable)
    end

    if data.voices then
        _G.charSelect.character_add_voice(data.model, data.voices)
    end
    if data.hasPowerMeter then
        _G.charSelect.character_add_health_meter(
            ct,
            {
                label = {
                    left = get_texture_info(data.id .. "health_left"),
                    right = get_texture_info(data.id .. "health_right"),
                },
                pie = {
                    [1] = get_texture_info(data.id .. "pie1"),
                    [2] = get_texture_info(data.id .. "pie2"),
                    [3] = get_texture_info(data.id .. "pie3"),
                    [4] = get_texture_info(data.id .. "pie4"),
                    [5] = get_texture_info(data.id .. "pie5"),
                    [6] = get_texture_info(data.id .. "pie6"),
                    [7] = get_texture_info(data.id .. "pie7"),
                    [8] = get_texture_info(data.id .. "pie8"),
                }
            }
        )
    end

    _G.charSelect.character_set_category(ct, LOONEY_TUNES_64)

    return ct
end

CT_BUGS = addLooneyTunesChar({
    id = 'bugs',
    name = 'Bugs Bunny',
    description = "Ain't he a stinker?",
    author = 'ThaGurlTilly',
    menuColor = '8b8b8b',
    model = smlua_model_util_get_id("bugs_bunny_geo"),
    charType = CT_LUIGI,
    palettes = {
        {
            palette = {
                [PANTS]  = "11ff00",
                [SHIRT]  = "ffffff",
                [GLOVES] = "ffffff",
                [SHOES]  = "ffffff",
                [HAIR]   = "8b8b8b",
                [SKIN]   = "fe98a3",
                [CAP]    = "ff6f00",
                [EMBLEM] = "ffffff"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_BUGS_CS_MENU
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Bugs Hello.ogg', 'Bugs Okey Dokey.ogg', 'Bugs Itsa Me.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Bugs Letsa Go.ogg',                                              -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Bugs Game Over.ogg',                                             -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Bugs Yah.ogg',                                                   -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Bugs Wah.ogg',                                                   -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Bugs Hoo.ogg',                                                   -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = { 'Bugs Yah Wah Hoo.ogg', 'Bugs Yah Wah Hoo 2.ogg' },           -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Bugs Hoohoo.ogg',                                                   -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Bugs Yahoo.ogg', 'Bugs Waha.ogg', 'Bugs Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Bugs Uh.ogg',                                                           -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Bugs Uh2.ogg',                                                         -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Bugs Uh2.ogg',                                                       -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Bugs Doh.ogg',                                                         -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Bugs Ooof.ogg',                                                       -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Bugs Uh.ogg',                                                        -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Bugs Haha.ogg',                                                       -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Bugs Haha.ogg',                                                     -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Bugs Yahoo.ogg',                                                     -- Long jump
        [CHAR_SOUND_DOH] = 'Bugs Doh.ogg',                                                         -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Bugs Whoa.ogg',                                                       -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Bugs Eeuh.ogg',                                                       -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Bugs Waaaooow.ogg',                                               -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Bugs Twirl Bounce.ogg',                                       -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Bugs Yah.ogg',                                            -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Bugs Wah2.ogg',                                                       -- Throwing something
        [CHAR_SOUND_HRMM] = 'Bugs Hrmm.ogg',                                                       -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Bugs Here We Go.ogg',                                           -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Bugs So Longa Bowser.ogg',                                 -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Bugs Attacked.ogg',                                               -- Damaged
        [CHAR_SOUND_PANTING] = 'Bugs Panting.ogg',                                                 -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Bugs Panting.ogg',                                            -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Bugs On Fire.ogg',                                                 -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Bugs Ima Tired.ogg',                                             -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Bugs Yawning.ogg',                                                 -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Bugs Snoring 1.ogg',                                              -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Bugs Snoring 2.ogg',                                              -- Exhale
        [CHAR_SOUND_SNORING3] = 'Bugs Snoring 3.ogg',                                              -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Bugs Coughing.ogg',                                              -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Bugs Coughing.ogg',                                              -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Bugs Coughing.ogg',                                              -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Bugs Dying.ogg',                                                     -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Bugs Drowning.ogg',                                               -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] = 'Bugs Mama Mia.ogg'                                                -- Booted out of level
    }
})

CT_DAFFY = addLooneyTunesChar({
    id = 'daffy',
    name = 'Daffy Duck',
    description = "You're Despicable...",
    author = 'ThaGurlTilly',
    menuColor = '8b8b8b',
    model = smlua_model_util_get_id("daffy_duck_geo"),
    charType = CT_LUIGI,
    palettes = {
        {
            palette = {
                [PANTS]  = "11ff00",
                [SHIRT]  = "ffffff",
                [GLOVES] = "ffffff",
                [SHOES]  = "ffffff",
                [HAIR]   = "0d0d0d",
                [SKIN]   = "fe98a3",
                [CAP]    = "ff6f00",
                [EMBLEM] = "ffffff"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_BUGS_CS_MENU
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = 'Daffy Okey Dokey.ogg',                           -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Daffy Lets A Go.ogg',                             -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Daffy Game Over.ogg',                             -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Daffy Yah.ogg',                                   -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Daffy Wah.ogg',                                   -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Daffy Hoo.ogg',                                   -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = { 'Daffy Wah2.ogg', 'Daffy Oh.ogg' },            -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Daffy Hoohoo.ogg',                                   -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Daffy Yahoo.ogg', 'Daffy Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Daffy Unh 02.ogg',                                       -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Daffy Unh.ogg',                                         -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Daffy Unh.ogg',                                       -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Daffy Doh.ogg',                                         -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Daffy Doh.ogg',                                        -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Daffy Ooph.ogg',                                      -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Daffy Haha.ogg',                                       -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Daffy Haha.ogg',                                     -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Daffy Yahoo.ogg',                                     -- Long jump
        [CHAR_SOUND_DOH] = 'Daffy Ooph.ogg',                                        -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Daffy Woah.ogg',                                       -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Daffy Ledge Climb.ogg',                                -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Daffy Waaaooow.ogg',                               -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Daffy Boing.ogg',                              -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Daffy Wah.ogg',                            -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Daffy Wah2.ogg',                                       -- Throwing something
        [CHAR_SOUND_HRMM] = 'Daffy Hrmm.ogg',                                       -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Daffy Here We Go.ogg',                           -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Daffy So Longa Bowser.ogg',                 -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Daffy Lose Health.ogg',                            -- Damaged
        [CHAR_SOUND_PANTING] = 'Daffy Ooh.ogg',                                     -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Daffy Ooh.ogg',                                -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Daffy Hot hot hot.ogg',                             -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Daffy Ima tired.ogg',                             -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Daffy Yawn.ogg',                                    -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Daffy Snore 01 inhale.ogg',                        -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Daffy Snore 02 exhale.ogg',                        -- Exhale
        [CHAR_SOUND_SNORING3] = 'Daffy Snore & Pasta.ogg',                          -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Daffy Cough.ogg',                                 -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Daffy Cough 1.ogg',                               -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Daffy Cough 2.ogg',                               -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Daffy Uhh Ooph.ogg',                                  -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Daffy Drowning.ogg',                               -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] = 'Daffy Mamma Mia.ogg'                               -- Booted out of level
    }
})

CT_PORKY = addLooneyTunesChar({
    id = 'porky',
    name = 'Porky Pig',
    description = "That's All Folks!",
    author = 'ThaGurlTilly',
    menuColor = '8b8b8b',
    model = smlua_model_util_get_id("porky_pig_geo"),
    charType = CT_TOAD,
    palettes = {
        {
            palette = {
                [PANTS]  = "ff0000",
                [SHIRT]  = "163fb5",
                [GLOVES] = "202020",
                [SHOES]  = "ffffff",
                [HAIR]   = "0d0d0d",
                [SKIN]   = "feafa7",
                [CAP]    = "ff6f00",
                [EMBLEM] = "ffffff"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_PORKY_CS_MENU
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Porky Okey Dokey.ogg', 'Porky Itsa Me.ogg', 'Porky Hello.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Porky Lets A Go.ogg',                                               -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Porky Game Over.ogg',                                               -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Porky Yah.ogg',                                                     -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Porky Wah.ogg',                                                     -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Porky Hoo.ogg',                                                     -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = { 'Porky Yah.ogg', 'Porky Yah2.ogg' },                             -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Porky Hoohoo.ogg',                                                     -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Porky Yahoo.ogg', 'Porky Waha.ogg', 'Porky Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Porky Uh.ogg',                                                             -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Porky Uh2.ogg',                                                           -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Porky Uh2.ogg',                                                         -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Porky Doh.ogg',                                                           -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Porky Doh.ogg',                                                          -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Porky Ooof2.ogg',                                                       -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Porky Haha.ogg',                                                         -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Porky Haha.ogg',                                                       -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Porky Yahoo.ogg',                                                       -- Long jump
        [CHAR_SOUND_WHOA] = 'Porky Woah.ogg',                                                         -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Porky Ooof2.ogg',                                                        -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Porky Waaaooow.ogg',                                                 -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Porky Boing.ogg',                                                -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Porky Wah.ogg',                                              -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Porky Wah2.ogg',                                                         -- Throwing something
        [CHAR_SOUND_HRMM] = 'Porky Hrmm.ogg',                                                         -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Porky Here We Go.ogg',                                             -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Porky So Longa Bowser.ogg',                                   -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Porky Attacked.ogg',                                                 -- Damaged
        [CHAR_SOUND_PANTING] = 'Porky Panting.ogg',                                                   -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Porky Panting.ogg',                                              -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Porky Burning.ogg',                                                   -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Porky Ima Tired.ogg',                                               -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Porky Yawn.ogg',                                                      -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Porky Snore 1 Inhale.ogg',                                           -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Porky Snore 2 Exhale.ogg',                                           -- Exhale
        [CHAR_SOUND_SNORING3] = 'Porky Snore and Pasta.ogg',                                          -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Porky Cough.ogg',                                                   -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Porky Cough.ogg',                                                   -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Porky Cough.ogg',                                                   -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Porky Game Over.ogg',                                                   -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Porky Drowning.ogg',                                                 -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] =
        'Porky Mama Mia.ogg'                                                                          -- Booted out of level
    }
})

CT_ELMER = addLooneyTunesChar({
    id = 'elmer',
    name = 'Elmer Fudd',
    description = "Be vewy, vewy quiet...",
    author = 'ThaGurlTilly',
    menuColor = '8b8b8b',
    model = smlua_model_util_get_id("elmer_fudd_geo"),
    charType = CT_TOAD,
    palettes = {
        {
            palette = {
                [PANTS]  = "aa6838",
                [SHIRT]  = "163fb5",
                [GLOVES] = "202020",
                [SHOES]  = "3a160f",
                [HAIR]   = "0d0d0d",
                [SKIN]   = "f8bc9f",
                [CAP]    = "ff1714",
                [EMBLEM] = "ffffff"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_ELMER_CS_MENU
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Elmer Okey Dokey.ogg', 'Elmer Hello.ogg', 'Elmer Itsa Me.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Elmer Letsa Go.ogg',                                                -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Elmer Game Over.ogg',                                               -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Elmer Yah.ogg',                                                     -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Elmer Wah.ogg',                                                     -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Elmer Hoo.ogg',                                                     -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = 'Elmer Yah Wah Hoo.ogg',                                           -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Elmer Hoohoo.ogg',                                                     -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Elmer Yahoo.ogg', 'Elmer Waha.ogg', 'Elmer Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Elmer Uh.ogg',                                                             -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Elmer Uh2.ogg',                                                           -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Elmer Uh2_2.ogg',                                                       -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Elmer Doh.ogg',                                                           -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Elmer Ooof.ogg',                                                         -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Elmer Uh.ogg',                                                          -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Elmer Haha.ogg',                                                         -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Elmer Haha.ogg',                                                       -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Elmer Yahoo.ogg',                                                       -- Long jump
        [CHAR_SOUND_DOH] = 'Elmer Doh.ogg',                                                           -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Elmer Whoa.ogg',                                                         -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Elmer Eeuh.ogg',                                                         -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Elmer Waaaooow.ogg',                                                 -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Elmer Boing.ogg',                                                -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Elmer Wah.ogg',                                              -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Elmer Wah2.ogg',                                                         -- Throwing something
        [CHAR_SOUND_HRMM] = 'Elmer Hrmm.ogg',                                                         -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Elmer Here We Go.ogg',                                             -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Elmer So Longa Bowser.ogg',                                   -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Elmer Attacked.ogg',                                                 -- Damaged
        [CHAR_SOUND_PANTING] = 'Elmer Panting.ogg',                                                   -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Elmer Panting.ogg',                                              -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Elmer On Fire.ogg',                                                   -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Elmer Ima Tired.ogg',                                               -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Elmer Yawn.ogg',                                                      -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Elmer Snore1.ogg',                                                   -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Elmer Snore2.ogg',                                                   -- Exhale
        [CHAR_SOUND_SNORING3] = 'Elmer Snore3.ogg',                                                   -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Elmer Cough.ogg',                                                   -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Elmer Cough.ogg',                                                   -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Elmer Cough.ogg',                                                   -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Elmer Dying.ogg',                                                       -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Elmer Drowning.ogg',                                                 -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] =
        'Elmer Mama Mia.ogg'                                                                          -- Booted out of level
    }
})

CT_SYLVESTER = addLooneyTunesChar({
    id = 'sylvester',
    name = 'Sylvester The Cat',
    description = "I tawt I taw him..",
    author = 'ThaGurlTilly',
    menuColor = '8b8b8b',
    model = smlua_model_util_get_id("sylvester_the_cat_geo"),
    charType = CT_LUIGI,
    palettes = {
        {
            palette = {
                [PANTS]  = "11ff00",
                [SHIRT]  = "ffffff",
                [GLOVES] = "ffffff",
                [SHOES]  = "ffffff",
                [HAIR]   = "0d0d0d",
                [SKIN]   = "fe412d",
                [CAP]    = "ff6f00",
                [EMBLEM] = "ffffff"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_SYLVESTER_CS_MENU
        }
    }
})

CT_MARVIN = addLooneyTunesChar({
    id = 'marvin',
    name = 'Marvin The Martian',
    description = "Where's the Boom?",
    author = 'ThaGurlTilly',
    menuColor = '8b8b8b',
    model = smlua_model_util_get_id("marvin_the_martian_geo"),
    charType = CT_TOAD,
    palettes = {
        {
            palette = {
                [PANTS]  = "ff0000",
                [SHIRT]  = "0a5e00",
                [GLOVES] = "ffffff",
                [SHOES]  = "ffffff",
                [HAIR]   = "fea536",
                [SKIN]   = "161616",
                [CAP]    = "ff6f00",
                [EMBLEM] = "ffffff"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_MARVIN_CS_MENU
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Marvin Okey Dokey.ogg', 'Marvin Hello.ogg', 'Marvin Itsa Me.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Marvin Letsa Go.ogg',                                                  -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Marvin Game Over.ogg',                                                 -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Marvin Yah.ogg',                                                       -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Marvin Yah.ogg',                                                       -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Marvin Uh.ogg',                                                        -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = { 'Marvin Yah Wah Hoo.ogg', 'Marvin Yah Wah Hoo 2.ogg' },             -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Marvin Ooof.ogg',                                                         -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Marvin Yahoo.ogg', 'Marvin Waha.ogg', 'Marvin Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Marvin Uh.ogg',                                                               -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Marvin Uh2.ogg',                                                             -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Marvin Uh2.ogg',                                                           -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Marvin Doh.ogg',                                                             -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Marvin Ooof.ogg',                                                           -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Marvin Uh.ogg',                                                            -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Marvin Haha.ogg',                                                           -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Marvin Haha.ogg',                                                         -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Marvin Yahoo.ogg',                                                         -- Long jump
        [CHAR_SOUND_DOH] = 'Marvin Doh.ogg',                                                             -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Marvin Whoa.ogg',                                                           -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Marvin Eeuh.ogg',                                                           -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Marvin Waaaooow.ogg',                                                   -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Marvin Twirl Bounce.ogg',                                           -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Marvin Wah.ogg',                                                -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Marvin Wah.ogg',                                                            -- Throwing something
        [CHAR_SOUND_HRMM] = 'Marvin Uh2.ogg',                                                            -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Marvin Here We Go.ogg',                                               -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Marvin So Longa Bowser.ogg',                                     -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Marvin Attacked.ogg',                                                   -- Damaged
        [CHAR_SOUND_PANTING] = 'Marvin Panting.ogg',                                                     -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Marvin Panting.ogg',                                                -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Marvin Waaaooow.ogg',                                                    -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Marvin Ima Tired.ogg',                                                 -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Marvin Yawning.ogg',                                                     -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING3] = 'Marvin Snoring 3.ogg',                                                  -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Marvin Coughing.ogg',                                                  -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Marvin Coughing.ogg',                                                  -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Marvin Coughing.ogg',                                                  -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Marvin Dying.ogg',                                                         -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Marvin Drowning.ogg',                                                   -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] =
        'Marvin Mama Mia.ogg'                                                                            -- Booted out of level
    }
})

CT_FOGHORN = addLooneyTunesChar({
    id = 'foghorn',
    name = 'Foghorn Leghorn',
    description = "I say I say!",
    author = 'ThaGurlTilly',
    menuColor = '8b8b8b',
    model = smlua_model_util_get_id("foghorn_leghorn_geo"),
    charType = CT_WALUIGI,
    camScale = 1.5,
    palettes = {
        {
            palette = {
                [PANTS]  = "ff4b00",
                [SHIRT]  = "ffffff",
                [GLOVES] = "ffffff",
                [SHOES]  = "ffffff",
                [HAIR]   = "5b0f00",
                [SKIN]   = "bf9430",
                [CAP]    = "472200",
                [EMBLEM] = "ffffff"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_FOGHORN_CS_MENU
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Foghorn Okey Dokey.ogg', 'Foghorn Hello.ogg', 'Foghorn Itsa Me.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Foghorn Letsa Go.ogg',                                                    -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Foghorn Game Over.ogg',                                                   -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Foghorn Yah.ogg',                                                         -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Foghorn Wah.ogg',                                                         -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Foghorn Hoo.ogg',                                                         -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = 'Foghorn Wah.ogg',                                                       -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Foghorn Hoohoo.ogg',                                                         -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Foghorn Yahoo.ogg', 'Foghorn Waha.ogg', 'Foghorn Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Foghorn Uh.ogg',                                                                 -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Foghorn Uh2.ogg',                                                               -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Foghorn Uh2.ogg',                                                             -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Foghorn Doh.ogg',                                                               -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Foghorn Ooof.ogg',                                                             -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Foghorn Ooof2.ogg',                                                           -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Foghorn Haha.ogg',                                                             -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Foghorn Haha.ogg',                                                           -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Foghorn Yahoo.ogg',                                                           -- Long jump
        [CHAR_SOUND_DOH] = 'Foghorn Doh.ogg',                                                               -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Foghorn Whoa.ogg',                                                             -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Foghorn Eeuh.ogg',                                                             -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Foghorn Waaaooow.ogg',                                                     -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Foghorn Twirl Bounce.ogg',                                             -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Foghorn Wah.ogg',                                                  -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Foghorn Wah2.ogg',                                                             -- Throwing something
        [CHAR_SOUND_HRMM] = 'Foghorn Hrmm.ogg',                                                             -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Foghorn Here We Go.ogg',                                                 -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Foghorn So Longa Bowser.ogg',                                       -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Foghorn Attacked.ogg',                                                     -- Damaged
        [CHAR_SOUND_PANTING] = 'Foghorn Panting.ogg',                                                       -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Foghorn Panting.ogg',                                                  -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Foghorn On Fire.ogg',                                                       -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Foghorn Ima Tired.ogg',                                                   -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Foghorn Yawning.ogg',                                                       -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Foghorn Snoring1.ogg',                                                     -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Foghorn Snoring2.ogg',                                                     -- Exhale
        [CHAR_SOUND_SNORING3] = 'Foghorn Snoring3.ogg',                                                     -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Foghorn Coughing.ogg',                                                    -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Foghorn Coughing.ogg',                                                    -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Foghorn Coughing.ogg',                                                    -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Foghorn Dying.ogg',                                                           -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Foghorn Drowning.ogg',                                                     -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] = 'Foghorn Mama Mia.ogg'                                                      -- Booted out of level
    }
})

_G.charSelect.credit_add(LOONEY_TUNES_64, "ThaGurlTilly", "Models")
_G.charSelect.credit_add(LOONEY_TUNES_64, "ProfeJavix", "Movesets")
_G.charSelect.credit_add(LOONEY_TUNES_64, "Warner", "Making the guy")
