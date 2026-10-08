local nps = gNetworkPlayers

local LOONEY_TUNES_64 = get_active_mod().name
local defaultLifeIcon = get_texture_info("exclamation-icon")
CT_THANKS_FOR_PLAYING_CLIPS = {}
CT_REPLACE_ACTS = {} ---@type ReplaceActInfo[]
LT_64_CHARS = {}

---@param data LTData
---@return integer
local function addLooneyTunesChar(data)
    local icon = defaultLifeIcon
    if mod_file_exists('textures/' .. data.id .. '-icon.tex') then
        icon = get_texture_info(data.id .. '-icon')
    end

    local ct = _G.charSelect.character_add(
        data.name,                 -- Character Name
        data.description,          -- Description
        data.author,               -- Credits
        data.menuColor,            -- Menu Color
        data.model,                -- Character Model
        data.charType or CT_MARIO, -- Override Character
        icon,                      -- Life Icon
        data.camScale or 1         -- Camera Scale
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

    local thanksClip = data.id .. '-thanks-for-playing.ogg'
    if mod_file_exists('sound/' .. thanksClip) then
        CT_THANKS_FOR_PLAYING_CLIPS[ct] = audio_sample_load(thanksClip)
    end

    if data.replaceActs then
        data.replaceActs.actsSet = data.replaceActs.actsSet or {}
        for _, act in ipairs(data.replaceActs.acts) do
            data.replaceActs.actsSet[act] = true
        end
        data.replaceActs.canGrab = data.replaceActs.canGrab or function() return false end
        CT_REPLACE_ACTS[ct] = data.replaceActs
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

    LT_64_CHARS[ct] = true

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
        [CHAR_SOUND_SNORING1] = 'Bugs Snoring1.ogg',                                                -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Bugs Snoring2.ogg',                                               -- Exhale
        [CHAR_SOUND_SNORING3] = 'Bugs Snoring3.ogg',                                               -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Bugs Coughing.ogg',                                              -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Bugs Coughing.ogg',                                              -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Bugs Coughing.ogg',                                              -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Bugs Dying.ogg',                                                     -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Bugs Drowning.ogg',                                               -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] = 'Bugs Mama Mia.ogg'                                                -- Booted out of level
    },
    replaceActs = {
        acts = { ACT_BUGS_LOLA_HOVER, ACT_BUGS_DIVE_POUND },
        param = function(m, incAct)
            if m.action == ACT_BUGS_LOLA_HOVER then
                m.marioBodyState.allowPartRotation = 0
            end

            if m.action == ACT_BUGS_DIVE_POUND then
                m.faceAngle.x = 0
            end

            if m.action == ACT_BUGS_MOVE_UNDERGROUND then
                m.squishTimer = 0
                m.invincTimer = 0
            end

            if incAct == ACT_TRIPLE_JUMP then
                set_mario_y_vel_based_on_fspeed(m, 69, 0)
                m.forwardVel = m.forwardVel * 0.8
                return 1
            end

            if incAct == ACT_GROUND_POUND then
                return 2
            end

            return -1
        end
    }
})

CT_DAFFY = addLooneyTunesChar({
    id = 'daffy',
    name = 'Daffy Duck',
    description = "You're Despicable...",
    author = 'ThaGurlTilly',
    menuColor = 'ff6f00',
    model = smlua_model_util_get_id("daffy_duck_geo"),
    charType = CT_LUIGI,
    palettes = {
        {
            palette = {
                [PANTS]  = "0d0d0d",
                [SHIRT]  = "0d0d0d",
                [GLOVES] = "0d0d0d",
                [SHOES]  = "ff6f00",
                [HAIR]   = "0d0d0d",
                [SKIN]   = "ff6f00",
                [CAP]    = "ff6f00",
                [EMBLEM] = "ff6f00"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_DAFFY_CS_MENU,
            [CHAR_ANIM_FIRST_PUNCH_FAST] = function (m)
                if m.action == ACT_DAFFY_MALLET_SWING then
                    return ANIM_DAFFY_MALLET_SWING
                end
            end,
            [CHAR_ANIM_SECOND_PUNCH] = function (m)
                if m.action == ACT_DAFFY_MALLET_POUND or m.action == ACT_DAFFY_MALLET_POUND_LAND then
                    return ANIM_DAFFY_MALLET_POUND
                end
            end
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = 'Daffy Okey Dokey.ogg',                                             -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Daffy Lets A Go.ogg',                                               -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Daffy Game Over.ogg',                                               -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Daffy Yah.ogg',                                                     -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Daffy Wah.ogg',                                                     -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Daffy Hoo.ogg',                                                     -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = { 'Daffy Yah Wah Hoo.ogg', 'Daffy Wah2.ogg' },                     -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Daffy Hoohoo.ogg',                                                     -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Daffy Yahoo.ogg', 'Daffy Waha.ogg', 'Daffy Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Daffy Uh.ogg',                                                             -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Daffy Uh2.ogg',                                                           -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Daffy Uh2.ogg',                                                         -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Daffy Doh.ogg',                                                           -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Daffy Ooof.ogg',                                                         -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Daffy Ooof.ogg',                                                        -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Daffy Haha.ogg',                                                         -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Daffy Haha.ogg',                                                       -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Daffy Yahoo.ogg',                                                       -- Long jump
        [CHAR_SOUND_DOH] = 'Daffy Doh.ogg',                                                           -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Daffy Whoa.ogg',                                                         -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Daffy Eeuh.ogg',                                                         -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Daffy Waaaooow.ogg',                                                 -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Daffy Twirl Bounce.ogg',                                         -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Daffy Hoohoo.ogg',                                              -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Daffy Wah2.ogg',                                                         -- Throwing something
        [CHAR_SOUND_HRMM] = 'Daffy Hrmm.ogg',                                                         -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Daffy Here We Go.ogg',                                             -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Daffy So Longa Bowser.ogg',                                   -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Daffy Attacked.ogg',                                                 -- Damaged
        [CHAR_SOUND_PANTING] = 'Daffy Panting.ogg',                                                   -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Daffy Panting.ogg',                                              -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Daffy On Fire.ogg',                                                   -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Daffy Ima tired.ogg',                                               -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Daffy Yawning.ogg',                                                   -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Daffy Snoring1.ogg',                                                 -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Daffy Snoring2.ogg',                                                 -- Exhale
        [CHAR_SOUND_SNORING3] = 'Daffy Snoring3.ogg',                                                 -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Daffy Coughing.ogg',                                                -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Daffy Coughing2.ogg',                                               -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Daffy Coughing3.ogg',                                               -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Daffy Dying.ogg',                                                       -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Daffy Drowning.ogg',                                                 -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] =
        'Daffy Mama Mia.ogg'                                                                          -- Booted out of level
    },
    replaceActs = {
        acts = { ACT_DAFFY_MALLET_SWING, ACT_DAFFY_MALLET_POUND, ACT_DAFFY_POUND },
        param = function(m, incAct)

            if incAct == ACT_PUNCHING or incAct == ACT_MOVE_PUNCHING then
                return 1
            elseif incAct == ACT_JUMP_KICK then
                return 2
            elseif incAct == ACT_GROUND_POUND then
                return 3
            end

            return -1
        end,
        canGrab = function (m)
            return m.action == ACT_DAFFY_MALLET_SWING and m.actionArg == 0
        end
    }
})

CT_PORKY = addLooneyTunesChar({
    id = 'porky',
    name = 'Porky Pig',
    description = "That's All Folks!",
    author = 'ThaGurlTilly',
    menuColor = 'feafa7',
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
        [CHAR_SOUND_YAH_WAH_HOO] = 'Porky Yah Wah Hoo.ogg',                             -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Porky Hoohoo.ogg',                                                     -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Porky Yahoo.ogg', 'Porky Waha.ogg', 'Porky Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Porky Uh.ogg',                                                             -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Porky Uh2.ogg',                                                           -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Porky Uh2_2.ogg',                                                         -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Porky Doh.ogg',                                                           -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Porky Ooof.ogg',                                                          -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Porky Ooof2.ogg',                                                       -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Porky Haha.ogg',                                                         -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Porky Haha.ogg',                                                       -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Porky Yahoo.ogg',                                                       -- Long jump
        [CHAR_SOUND_WHOA] = 'Porky Whoa.ogg',                                                         -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Porky Eeuh.ogg',                                                        -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Porky Waaaooow.ogg',                                                 -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Porky Twirl Bounce.ogg',                                         -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Porky Ground Pound Wah.ogg',                                              -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Porky Wah2.ogg',                                                         -- Throwing something
        [CHAR_SOUND_HRMM] = 'Porky Hrmm.ogg',                                                         -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Porky Here We Go.ogg',                                             -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Porky So Longa Bowser.ogg',                                   -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Porky Attacked.ogg',                                                 -- Damaged
        [CHAR_SOUND_PANTING] = 'Porky Panting.ogg',                                                   -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Porky Panting.ogg',                                              -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Porky On Fire.ogg',                                                   -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Porky Ima Tired.ogg',                                               -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Porky Yawning.ogg',                                                   -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Porky Snoring1.ogg',                                                 -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Porky Snoring2.ogg',                                                 -- Exhale
        [CHAR_SOUND_SNORING3] = 'Porky Snoring3.ogg',                                                 -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Porky Coughing.ogg',                                                -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Porky Coughing.ogg',                                                -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Porky Coughing.ogg',                                                -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Porky Dying.ogg',                                                       -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Porky Drowning.ogg',                                                 -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] =
        'Porky Mama Mia.ogg'                                                                          -- Booted out of level
    }
})

CT_ELMER = addLooneyTunesChar({
    id = 'elmer',
    name = 'Elmer Fudd',
    description = "Be vewy, vewy quiet...",
    author = 'Tanooki',
    menuColor = 'aa6838',
    model = smlua_model_util_get_id("elmer_fudd_geo"),
    charType = CT_TOAD,
    palettes = {
        {
            palette = {
                [PANTS]  = "aa6838",
                [SHIRT]  = "aa6838",
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
            [_G.charSelect.CS_ANIM_MENU] = ANIM_ELMER_CS_MENU,
            [CHAR_ANIM_FIRST_PUNCH_FAST] = function(m)
                if m.action == ACT_ELMER_SHOOT_SHOTGUN then
                    return ternary(m.forwardVel == 0, ANIM_ELMER_SHOOT_SHOTGUN, ANIM_ELMER_SHOOT_SHOTGUN_SLIDE)
                end
            end,
            [CHAR_ANIM_AIR_KICK] = function(m)
                if m.action == ACT_ELMER_AIR_SHOOT_SHOTGUN then
                    return ANIM_ELMER_SHOOT_SHOTGUN_AIR
                end
            end
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
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Elmer Twirl Bounce.ogg',                                         -- Bouncing off of a flower spring
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
    },
    replaceActs = {
        acts = { ACT_ELMER_SHOOT_SHOTGUN, ACT_ELMER_AIR_SHOOT_SHOTGUN },
        param = function (m, incAct)
            if incAct== ACT_PUNCHING or incAct == ACT_MOVE_PUNCHING or incAct == ACT_JUMP_KICK then
                return ternary(m.floorHeight == m.pos.y, 1, 2)
            end
            return -1
        end,
        canGrab = function (m)
            return m.floorHeight == m.pos.y
        end
    }
})

CT_SYLVESTER = addLooneyTunesChar({
    id = 'sylvester',
    name = 'Sylvester The Cat',
    description = "I tawt I taw him..",
    author = 'ThaGurlTilly',
    menuColor = '0d0d0d',
    model = smlua_model_util_get_id("sylvester_the_cat_geo"),
    charType = CT_LUIGI,
    camScale = 1.5,
    palettes = {
        {
            palette = {
                [PANTS]  = "0d0d0d",
                [SHIRT]  = "0d0d0d",
                [GLOVES] = "ffffff",
                [SHOES]  = "ffffff",
                [HAIR]   = "0d0d0d",
                [SKIN]   = "ffffff",
                [CAP]    = "ff6f00",
                [EMBLEM] = "730600"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_SYLVESTER_CS_MENU
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Sylvester Hello.ogg', 'Sylvester Okey Dokey.ogg', 'Sylvester Itsa Me.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Sylvester Letsa Go.ogg',                                              -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Sylvester Game Over.ogg',                                             -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Sylvester Yah.ogg',                                                   -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Sylvester Wah.ogg',                                                   -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Sylvester Hoo.ogg',                                                   -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = 'Sylvester Yah Wah Hoo.ogg',           -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Sylvester Hoohoo.ogg',                                                   -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Sylvester Yahoo.ogg', 'Sylvester Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Sylvester Uh.ogg',                                                           -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Sylvester Uh.ogg',                                                         -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Sylvester Uh.ogg',                                                       -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Sylvester Ooof.ogg',                                                         -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Sylvester Ooof.ogg',                                                       -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Sylvester Uh.ogg',                                                        -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Sylvester Yippee.ogg',                                                       -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Sylvester Yippee.ogg',                                                     -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Sylvester Yahoo.ogg',                                                     -- Long jump
        [CHAR_SOUND_DOH] = 'Sylvester Ooof.ogg',                                                         -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Sylvester Ooof.ogg',                                                       -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Sylvester Eeuh.ogg',                                                       -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Sylvester Waaaooow.ogg',                                               -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Sylvester Twirl Bounce.ogg',                                       -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Sylvester Hoo.ogg',                                            -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Sylvester Wah2.ogg',                                                       -- Throwing something
        [CHAR_SOUND_HRMM] = 'Sylvester Hrmm.ogg',                                                       -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Sylvester Here We Go.ogg',                                           -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Sylvester So Longa Bowser.ogg',                                 -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Sylvester Attacked.ogg',                                               -- Damaged
        [CHAR_SOUND_PANTING] = 'Sylvester Panting.ogg',                                                 -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Sylvester Panting.ogg',                                            -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Sylvester On Fire.ogg',                                                 -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Sylvester Ima Tired.ogg',                                             -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Sylvester Yawning.ogg',                                                 -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Sylvester Snoring1.ogg',                                                -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Sylvester Snoring2.ogg',                                               -- Exhale
        [CHAR_SOUND_SNORING3] = 'Sylvester Snoring3.ogg',                                               -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Sylvester Panting.ogg',                                              -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Sylvester Panting.ogg',                                              -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Sylvester Panting.ogg',                                              -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Sylvester Dying.ogg',                                                     -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Sylvester Dying.ogg',                                               -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] = 'Sylvester Mama Mia.ogg'                                                -- Booted out of level
    },
    replaceActs = {
        acts = { ACT_SYLVESTER_WALL_CRAWL, ACT_SYLVESTER_TWEETY_GLIDE },
        param = function(m, incAct)

            if m.action == ACT_AIR_HIT_WALL then
                m.faceAngle.x = 0
                m.faceAngle.z = 0
            end

            if m.action == ACT_SYLVESTER_TWEETY_FIGHT then
                m.faceAngle.x = 0
                m.squishTimer = 0
                m.usedObj = nil
            end

            if incAct == ACT_AIR_HIT_WALL then
                return 1
            end

            if incAct == ACT_BACKFLIP and m.flags & MARIO_CAP_ON_HEAD ~= 0 then
                m.vel.y = 80
                return 2
            end

            return -1
        end
    }
})

CT_MARVIN = addLooneyTunesChar({
    id = 'marvin',
    name = 'Marvin The Martian',
    description = "Where's the Boom?",
    author = 'ThaGurlTilly',
    menuColor = '0a5e00',
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
                [CAP]    = "0a5e00",
                [EMBLEM] = "fea536"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_MARVIN_CS_MENU,
            [CHAR_ANIM_FIRST_PUNCH_FAST] = function(m)
                if m.action == ACT_MARVIN_SHOOT_LASER then
                    return ANIM_MARVIN_SHOOT_LASER
                elseif m.action == ACT_MARVIN_AIR_SHOOT_LASER then
                    return ANIM_MARVIN_SHOOT_LASER_AIR
                end
            end,
            [CHAR_ANIM_PICK_UP_LIGHT_OBJ] = function (m)
                if m.action == ACT_MARVIN_GRAB_TNT then
                    return ANIM_MARVIN_GRAB_TNT
                end
            end
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
        [CHAR_SOUND_SNORING3] = 'Marvin Snoring3.ogg',                                                  -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Marvin Coughing.ogg',                                                  -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Marvin Coughing.ogg',                                                  -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Marvin Coughing.ogg',                                                  -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Marvin Dying.ogg',                                                         -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Marvin Drowning.ogg',                                                   -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] =
        'Marvin Mama Mia.ogg'                                                                            -- Booted out of level
    },
    replaceActs = {
        acts = { ACT_MARVIN_SHOOT_LASER, ACT_MARVIN_AIR_SHOOT_LASER },
        param = function (m, incAct)
            if incAct == ACT_PUNCHING or incAct == ACT_MOVE_PUNCHING or incAct == ACT_JUMP_KICK then
                return ternary(m.floorHeight == m.pos.y, 1, 2)
            end
            return -1
        end,
        canGrab = function (m)
            return m.floorHeight == m.pos.y
        end
    }
})

CT_TAZ = addLooneyTunesChar({
    id = 'taz',
    name = 'Tasmanian Devil',
    description = "*Unintelligible*",
    author = 'Tanooki',
    menuColor = '9d535a',
    model = smlua_model_util_get_id("taz_devil_geo"),
    charType = CT_LUIGI,
    palettes = {
        {
            palette = {
                [PANTS]  = "9d535a",
                [SHIRT]  = "9d535a",
                [GLOVES] = "9d535a",
                [SHOES]  = "9d535a",
                [HAIR]   = "9d535a",
                [SKIN]   = "d9c192",
                [CAP]    = "ff96c1",
                [EMBLEM] = "9d535a"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_TAZ_CS_MENU,
            [CHAR_ANIM_FIRST_PUNCH_FAST] = function (m)
                if m.action == ACT_TAZ_TORNADO_START then
                    return ANIM_TAZ_TORNADO_START
                end
            end
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Taz Okey Dokey.ogg', 'Taz Hello.ogg', 'Taz Itsa Me.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Taz Letsa Go.ogg',                                            -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Taz Game Over.ogg',                                           -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Taz Yah.ogg',                                                 -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Taz Wah.ogg',                                                 -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Taz Hoo.ogg',                                                 -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = 'Taz Yah Wah Hoo.ogg',                                       -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Taz Hoohoo.ogg',                                                 -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Taz Yahoo.ogg', 'Taz Waha.ogg', 'Taz Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Taz Uh.ogg',                                                         -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Taz Uh2.ogg',                                                       -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Taz Uh2.ogg',                                                     -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Taz Doh.ogg',                                                       -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Taz Ooof.ogg',                                                     -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Taz Ooof.ogg',                                                    -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Taz Haha.ogg',                                                     -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Taz Haha.ogg',                                                   -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Taz Yahoo.ogg',                                                   -- Long jump
        [CHAR_SOUND_DOH] = 'Taz Doh.ogg',                                                       -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Taz Whoa.ogg',                                                     -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Taz Eeuh.ogg',                                                     -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Taz Waaaooow.ogg',                                             -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Taz Twirl Bounce.ogg',                                     -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Taz Ground Pound Wah.ogg',                             -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Taz Wah2.ogg',                                                     -- Throwing something
        [CHAR_SOUND_HRMM] = 'Taz Hrmm.ogg',                                                     -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Taz Here We Go.ogg',                                         -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Taz So Longa Bowser.ogg',                               -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Taz Attacked.ogg',                                             -- Damaged
        [CHAR_SOUND_PANTING] = 'Taz Panting.ogg',                                               -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Taz Panting.ogg',                                          -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Taz On Fire.ogg',                                               -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Taz Ima Tired.ogg',                                           -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Taz Yawning.ogg',                                               -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Taz Snoring1.ogg',                                             -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Taz Snoring2.ogg',                                             -- Exhale
        [CHAR_SOUND_SNORING3] = 'Taz Snoring3.ogg',                                             -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Taz Coughing.ogg',                                            -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Taz Coughing.ogg',                                            -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Taz Coughing.ogg',                                            -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Taz Dying.ogg',                                                   -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Taz Drowning.ogg',                                             -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] =
        'Taz Mama Mia.ogg'                                                                      -- Booted out of level
    },
    replaceActs = {
        acts = { ACT_TAZ_TORNADO_START, ACT_TAZ_TORNADO_ATTACK },
        param = function(m, incAct)

            if m.action == ACT_TAZ_TORNADO_ATTACK then
                m.twirlYaw = 0
                m.invincTimer = 0
            end

            if incAct == ACT_TAZ_TORNADO_ATTACK then
                m.twirlYaw = m.faceAngle.y
            end

            if m.floorHeight == m.pos.y then
                if incAct == ACT_PUNCHING or incAct == ACT_MOVE_PUNCHING then
                    return ternary(m.forwardVel < 10, 1, 2)
                elseif incAct == ACT_DIVE then
                    return 2
                end
            end

            return -1
        end,
        canGrab = function (m)
            return m.action == ACT_TAZ_TORNADO_START or (m.action == ACT_TAZ_TORNADO_ATTACK and m.actionTimer <= 10)
        end
    }
})

CT_FOGHORN = addLooneyTunesChar({
    id = 'foghorn',
    name = 'Foghorn Leghorn',
    description = "I say I say!",
    author = 'Tanooki',
    menuColor = '5b0f00',
    model = smlua_model_util_get_id("foghorn_leghorn_geo"),
    charType = CT_WALUIGI,
    camScale = 1.5,
    palettes = {
        {
            palette = {
                [PANTS]  = "ffffff",
                [SHIRT]  = "ffffff",
                [GLOVES] = "ffffff",
                [SHOES]  = "fe7600",
                [HAIR]   = "ff4b00",
                [SKIN]   = "5b0f00",
                [CAP]    = "472200",
                [EMBLEM] = "bf9430"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_FOGHORN_CS_MENU,
            [CHAR_ANIM_FIRST_PUNCH_FAST] = function (m)
                if m.action == ACT_FOGHORN_SLAP_CHARGE then
                    return ANIM_FOGHORN_SLAP_START
                end
            end,
            [CHAR_ANIM_SECOND_PUNCH] = function (m)
                if m.action == ACT_FOGHORN_SLAP_CHARGE then
                    return ternary(m.forwardVel == 0, ANIM_FOGHORN_SLAP_CHARGE, ANIM_FOGHORN_SLAP_CHARGE_TIPTOE)
                end
            end,
            [CHAR_ANIM_SECOND_PUNCH_FAST] = function (m)
                if m.action == ACT_FOGHORN_SLAP_RELEASE then
                    return ANIM_FOGHORN_SLAP_RELEASE
                end
            end
        }
    },
    voices = {
        [CHAR_SOUND_HELLO] = 'Foghorn Itsa Me.ogg', --extra
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
        [CHAR_SOUND_MAMA_MIA] =
        'Foghorn Mama Mia.ogg'                                                                              -- Booted out of level
    },
    replaceActs = {
        acts = { ACT_FOGHORN_SLAP_CHARGE },
        param = function(m, incAct)
            if incAct == ACT_MOVE_PUNCHING or incAct == ACT_PUNCHING then
                mario_set_forward_vel(m, 0)
                return 1
            end
            return -1
        end,
        canGrab = function (m)
            return true
        end
    }
})

CT_LOLA = addLooneyTunesChar({
    id = 'lola',
    name = 'Lola Bunny',
    description = "Don't call her 'doll",
    author = 'LotsaSpaget',
    menuColor = 'e4bc5a',
    model = smlua_model_util_get_id("lola_bunny_geo"),
    charType = CT_LUIGI,
    palettes = {
        {
            palette = {
                [PANTS]  = "7a53c3",
                [SHIRT]  = "eaa500",
                [GLOVES] = "ffffff",
                [SHOES]  = "fee2b0",
                [HAIR]   = "e4bc5a",
                [SKIN]   = "cb7350",
                [CAP]    = "fee2b0",
                [EMBLEM] = "fe98a3"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_LOLA_CS_MENU
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Lola Hello.ogg', 'Lola Okey Dokey.ogg', 'Lola Itsa Me.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Lola Letsa Go.ogg',                                              -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Lola Game Over.ogg',                                             -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Lola Yah.ogg',                                                   -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Lola Wah.ogg',                                                   -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Lola Hoo.ogg',                                                   -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = 'Lola Wah.ogg',                                                 -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Lola Hoohoo.ogg',                                                   -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = 'Lola Yahoo.ogg',                                         -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Lola Uh.ogg',                                                           -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Lola Uh2.ogg',                                                         -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Lola Uh2_2.ogg',                                                     -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Lola Ooof2.ogg',                                                       -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Lola Ooof.ogg',                                                       -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Lola Ooof2.ogg',                                                     -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Lola Hoo.ogg',                                                       -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Lola Hoo.ogg',                                                     -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Lola Yahoo.ogg',                                                     -- Long jump
        [CHAR_SOUND_DOH] = 'Lola Ooof.ogg',                                                        -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Lola Ooof2.ogg',                                                      -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Lola Eeuh.ogg',                                                       -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Lola Waaaooow.ogg',                                               -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Lola Twirl Bounce.ogg',                                       -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Lola Wah.ogg',                                            -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Lola Uh2_2.ogg',                                                      -- Throwing something
        [CHAR_SOUND_HRMM] = 'Lola Hrmm.ogg',                                                       -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Lola Here We Go.ogg',                                           -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Lola So Longa Bowser.ogg',                                 -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Lola Attacked.ogg',                                               -- Damaged
        [CHAR_SOUND_PANTING] = 'Lola Snoring2.ogg',                                                -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Lola Snoring2.ogg',                                           -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Lola On Fire.ogg',                                                 -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Lola Ima Tired.ogg',                                             -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Lola Yawning.ogg',                                                 -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Lola Snoring1.ogg',                                               -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Lola Snoring2.ogg',                                               -- Exhale
        [CHAR_SOUND_SNORING3] = 'Lola Snoring3.ogg',                                               -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Lola Snoring2.ogg',                                              -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Lola Snoring2.ogg',                                              -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Lola Snoring2.ogg',                                              -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Lola Dying.ogg',                                                     -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Lola Drowning.ogg',                                               -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] = 'Lola Mama Mia.ogg'                                                -- Booted out of level
    },
    replaceActs = {
        acts = { ACT_BUGS_LOLA_HOVER },
        param = function(m, incAct)

            if incAct == ACT_TRIPLE_JUMP then
                set_mario_y_vel_based_on_fspeed(m, 69, 0)
                m.forwardVel = m.forwardVel * 0.8
                return 1
            end

            return -1
        end
    }
})

CT_SAM = addLooneyTunesChar({
    id = 'sam',
    name = 'Yosemite Sam',
    description = "Great horny toads!",
    author = 'Tanooki',
    menuColor = 'ef2e00',
    model = smlua_model_util_get_id("sam_yosemite_geo"),
    charType = CT_TOAD,
    palettes = {
        {
            palette = {
                [PANTS]  = "0073d6",
                [SHIRT]  = "cb2016",
                [GLOVES] = "f0cbbf",
                [SHOES]  = "000000",
                [HAIR]   = "ef2e00",
                [SKIN]   = "f0cbbf",
                [CAP]    = "ffda8e",
                [EMBLEM] = "cbba00"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_SAM_CS_MENU,
            [CHAR_ANIM_CROUCHING] = function(m)
                if m.action == ACT_SAM_SHOOT_PISTOL then
                    return ANIM_SAM_UNHOLSTER
                end
            end,
            [CHAR_ANIM_STOP_CROUCHING] = function(m)
                if m.action == ACT_SAM_SHOOT_PISTOL then
                    return ANIM_SAM_HOLSTER
                end
            end,
            [CHAR_ANIM_FIRST_PUNCH_FAST] = function(m)
                if m.action == ACT_SAM_SHOOT_PISTOL then
                    return ANIM_SAM_SHOOT_LEFT
                end
            end,
            [CHAR_ANIM_SECOND_PUNCH_FAST] = function(m)
                if m.action == ACT_SAM_SHOOT_PISTOL then
                    return ANIM_SAM_SHOOT_RIGHT
                end
            end,
            [CHAR_ANIM_AIR_KICK] = function (m)
                if m.action == ACT_SAM_AIR_SHOOT_PISTOL then
                    return ANIM_SAM_SHOOT_DOWN
                end
            end,
            [CHAR_ANIM_CROUCH_FROM_SLIDE_KICK] = function (m)
                if m.action == ACT_SAM_SHOULDER_BASH then
                    return ANIM_SAM_BASH_START
                end
            end,
            [CHAR_ANIM_SLIDE_KICK] = function (m)
                if m.action == ACT_SAM_SHOULDER_BASH then
                    return ANIM_SAM_BASH_RUN
                end
            end
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Sam Hello.ogg', 'Sam Okey Dokey.ogg', 'Sam Itsa Me.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Sam Letsa Go.ogg',                                            -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Sam Game Over.ogg',                                           -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Sam Yah.ogg',                                                 -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Sam Wah.ogg',                                                 -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Sam Hoo.ogg',                                                 -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = 'Sam Yah Wah Hoo.ogg',                                       -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Sam Hoo.ogg',                                                    -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Sam Yahoo.ogg', 'Sam Waha.ogg', 'Sam Yippee.ogg' }, -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Sam Uh.ogg',                                                         -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Sam Uh2.ogg',                                                       -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Sam Uh2_2.ogg',                                                   -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Sam Doh.ogg',                                                       -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Sam Ooof.ogg',                                                     -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Sam Ooof2.ogg',                                                   -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Sam Haha.ogg',                                                     -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Sam Haha.ogg',                                                   -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Sam Yahoo.ogg',                                                   -- Long jump
        [CHAR_SOUND_DOH] = 'Sam Doh.ogg',                                                       -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Sam Whoa.ogg',                                                     -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Sam Eeuh.ogg',                                                     -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Sam Waaaooow.ogg',                                             -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Sam Twirl Bounce.ogg',                                     -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Sam Wah.ogg',                                          -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Sam Wah2.ogg',                                                     -- Throwing something
        [CHAR_SOUND_HRMM] = 'Sam Hrmm.ogg',                                                     -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Sam Here We Go.ogg',                                         -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Sam So Longa Bowser.ogg',                               -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Sam Attacked.ogg',                                             -- Damaged
        [CHAR_SOUND_PANTING] = 'Sam Panting.ogg',                                               -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Sam Panting.ogg',                                          -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Sam On Fire.ogg',                                               -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Sam Ima Tired.ogg',                                           -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Sam Yawning.ogg',                                               -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING1] = 'Sam Snoring1.ogg',                                             -- Snore Inhale
        [CHAR_SOUND_SNORING2] = 'Sam Snoring2.ogg',                                             -- Exhale
        [CHAR_SOUND_SNORING3] = 'Sam Snoring3.ogg',                                             -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Sam Coughing.ogg',                                            -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Sam Coughing.ogg',                                            -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Sam Coughing.ogg',                                            -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Sam Dying.ogg',                                                   -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Sam Drowning.ogg',                                             -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] = 'Sam Mama Mia.ogg'                                              -- Booted out of level
    },
    replaceActs = {
        acts = { ACT_SAM_SHOOT_PISTOL, ACT_SAM_SHOULDER_BASH },
        param = function(m, incAct)
            if incAct == ACT_PUNCHING or incAct == ACT_MOVE_PUNCHING then
                return 1
            elseif incAct == ACT_SLIDE_KICK or incAct == ACT_SLIDE_KICK_SLIDE then
                return 2
            end
            return -1
        end,
        canGrab = function (m)
            return m.action == ACT_SAM_SHOOT_PISTOL and m.actionState == 0
        end
    }
})

CT_WILE = addLooneyTunesChar({
    id = 'wile',
    name = 'Wile E. Coyote',
    description = "ACME S*CKS",
    author = 'Tanooki',
    menuColor = '4d2c18',
    model = smlua_model_util_get_id("wile_e_coyote_geo"),
    charType = CT_WALUIGI,
    camScale = 1.5,
    palettes = {
        {
            palette = {
                [PANTS]  = "4d2c18",
                [SHIRT]  = "4d2c18",
                [GLOVES] = "4d2c18",
                [SHOES]  = "4d2c18",
                [HAIR]   = "4d2c18",
                [SKIN]   = "fec179",
                [CAP]    = "0000ff",
                [EMBLEM] = "4d2c18"
            }
        }
    },
    animData = {
        animTable = {
            [_G.charSelect.CS_ANIM_MENU] = ANIM_WILE_CS_MENU,
            [CHAR_ANIM_IDLE_HEAD_CENTER] = function(m)
                if m.action == ACT_WILE_AIR_WALK then
                    return ANIM_WILE_IN_AIR_REALIZATION
                end
            end,
            [CHAR_ANIM_STOP_CROUCHING] = function (m)
                if m.action == ACT_WILE_ROCKET_JUMP then
                    return ANIM_WILE_ROCKET_JUMP_START
                end
            end
        }
    },
    voices = {
        [CHAR_SOUND_OKEY_DOKEY] = { 'Wile E Okey Dokey.ogg', 'Wile E Hello.ogg', 'Wile E Itsa Me.ogg' }, -- Starting game
        [CHAR_SOUND_LETS_A_GO] = 'Wile E Letsa Go.ogg',                                                  -- Starting level
        [CHAR_SOUND_GAME_OVER] = 'Wile E Game Over.ogg',                                                 -- Game Overed
        [CHAR_SOUND_PUNCH_YAH] = 'Wile E Yah.ogg',                                                       -- Punch 1
        [CHAR_SOUND_PUNCH_WAH] = 'Wile E Yah.ogg',                                                       -- Punch 2
        [CHAR_SOUND_PUNCH_HOO] = 'Wile E Hoo.ogg',                                                       -- Punch 3
        [CHAR_SOUND_YAH_WAH_HOO] = { 'Wile E Yah Wah Hoo.ogg', 'Wile E Yah Wah Hoo 2.ogg' },             -- First Jump Sounds
        [CHAR_SOUND_HOOHOO] = 'Wile E Hoohoo.ogg',                                                       -- Second jump sound
        [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = { 'Wile E Yahoo.ogg', 'Wile E Yippee.ogg' },                    -- Triple jump sounds
        [CHAR_SOUND_UH] = 'Wile E Uh.ogg',                                                               -- Soft wall bonk
        [CHAR_SOUND_UH2] = 'Wile E Uh.ogg',                                                              -- Quick ledge get up
        [CHAR_SOUND_UH2_2] = 'Wile E Uh.ogg',                                                            -- Landing after long jump
        [CHAR_SOUND_DOH] = 'Wile E Uh.ogg',                                                              -- Hard wall bonk
        [CHAR_SOUND_OOOF] = 'Wile E Uh.ogg',                                                             -- Attacked in air
        [CHAR_SOUND_OOOF2] = 'Wile E Uh.ogg',                                                            -- Land from hard bonk
        [CHAR_SOUND_HAHA] = 'Wile E Haha.ogg',                                                           -- Landing triple jump
        [CHAR_SOUND_HAHA_2] = 'Wile E Haha.ogg',                                                         -- Landing in water from big fall
        [CHAR_SOUND_YAHOO] = 'Wile E Yahoo.ogg',                                                         -- Long jump
        [CHAR_SOUND_DOH] = 'Wile E Uh.ogg',                                                              -- Long jump wall bonk
        [CHAR_SOUND_WHOA] = 'Wile E Whoa.ogg',                                                           -- Grabbing ledge
        [CHAR_SOUND_EEUH] = 'Wile E Eeuh.ogg',                                                           -- Climbing over ledge
        [CHAR_SOUND_WAAAOOOW] = 'Wile E Waaaooow.ogg',                                                   -- Falling a long distance
        [CHAR_SOUND_TWIRL_BOUNCE] = 'Wile E Twirl Bounce.ogg',                                           -- Bouncing off of a flower spring
        [CHAR_SOUND_GROUND_POUND_WAH] = 'Wile E Yah Wah Hoo 2.ogg',                                      -- Ground Pound after startup
        [CHAR_SOUND_WAH2] = 'Wile E Yah Wah Hoo 2.ogg',                                                  -- Throwing something
        [CHAR_SOUND_HRMM] = 'Wile E Hrmm.ogg',                                                           -- Lifting something
        [CHAR_SOUND_HERE_WE_GO] = 'Wile E Here We Go.ogg',                                               -- Star get
        [CHAR_SOUND_SO_LONGA_BOWSER] = 'Wile E So Longa Bowser.ogg',                                     -- Throwing Bowser
        --DAMAGE
        [CHAR_SOUND_ATTACKED] = 'Wile E Attacked.ogg',                                                   -- Damaged
        [CHAR_SOUND_PANTING] = 'Wile E Panting.ogg',                                                     -- Low health
        [CHAR_SOUND_PANTING_COLD] = 'Wile E Panting.ogg',                                                -- Getting cold
        [CHAR_SOUND_ON_FIRE] = 'Wile E On Fire.ogg',                                                     -- Burned
        --SLEEP SOUNDS
        [CHAR_SOUND_IMA_TIRED] = 'Wile E Ima Tired.ogg',                                                 -- Mario feeling tired
        [CHAR_SOUND_YAWNING] = 'Wile E Yawning.ogg',                                                     -- Mario yawning before he sits down to sleep
        [CHAR_SOUND_SNORING3] = 'Wile E Snoring3.ogg',                                                   -- Sleep talking / mumbling
        --COUGHING (USED IN THE GAS MAZE)
        [CHAR_SOUND_COUGHING1] = 'Wile E Panting.ogg',                                                   -- Cough take 1
        [CHAR_SOUND_COUGHING2] = 'Wile E Panting.ogg',                                                   -- Cough take 2
        [CHAR_SOUND_COUGHING3] = 'Wile E Panting.ogg',                                                   -- Cough take 3
        --DEATH
        [CHAR_SOUND_DYING] = 'Wile E Dying.ogg',                                                         -- Dying from damage
        [CHAR_SOUND_DROWNING] = 'Wile E Dying.ogg',                                                      -- Running out of air underwater
        [CHAR_SOUND_MAMA_MIA] =
        'Wile E Mama Mia.ogg'                                                                            -- Booted out of level
    },
    replaceActs = {
        acts = { ACT_WILE_AIR_WALK, ACT_WILE_ROCKET_JUMP },
        param = function(m, incAct)

            if m.action == ACT_WILE_ROCKET_JUMP or m.action == ACT_WILE_ROCKET_EXPLODE then
                m.faceAngle.x = 0
            end

            if incAct == ACT_BACKFLIP then
                return 2
            end

            if m.forwardVel >= 25 and incAct == ACT_FREEFALL and m.action == ACT_WALKING then
                local colData = collision_get_temp_wall_collision_data()

                colData.x = m.pos.x
                colData.y = m.pos.y
                colData.z = m.pos.z
                colData.radius = 10
                colData.offsetY = -10

                if find_wall_collisions(colData) ~= 0 then
                    local floorHeight, floor = find_floor(colData.x, colData.y, colData.z)
                    if floor and colData.y - floorHeight > 160 then
                        local wall = colData.walls[colData.numWalls]
                        if abs_angle_diff(m.faceAngle.y, atan2s(wall.normal.z, wall.normal.x)) < 0x3555 then
                            return 1
                        end
                    end
                end
            end

            return -1
        end
    }
})

_G.charSelect.credit_add(LOONEY_TUNES_64, "ThaGurlTilly", "Models")
_G.charSelect.credit_add(LOONEY_TUNES_64, "ProfeJavix", "Movesets")
_G.charSelect.credit_add(LOONEY_TUNES_64, "LotsaSpaget", "Character Icons")
_G.charSelect.credit_add(LOONEY_TUNES_64, "Warner", "Making the guy")
