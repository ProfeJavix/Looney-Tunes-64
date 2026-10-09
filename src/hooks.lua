local states = gMarioStates
local playerTable = gPlayerSyncTable

local hooks = {}

local STREAM_AS_SEQS = {
    [SEQ_EVENT_CUTSCENE_CREDITS] = {
        audio = audio_stream_load('Music Credits.ogg'),
        looping = true
    },
    [SEQ_LEVEL_SLIDE] = {
        audio = audio_stream_load('Music Slide.ogg'),
        looping = true,
        loopStart = 1488385,
        loopEnd = 2945664
    }
}

local curPlayingSeqs = {}
local menuWasOpen = false

function hooks.update()

    if playerTable[0].blockCTActsTimer > 0 then
        playerTable[0].blockCTActsTimer = playerTable[0].blockCTActsTimer - 1
    end

    if _G.charSelect.is_menu_open() then
        if not menuWasOpen then
            for _, stream in pairs(curPlayingSeqs) do
                audio_stream_set_volume(stream, 0)
            end
            menuWasOpen = true
        end
    elseif menuWasOpen then
        for player, stream in pairs(curPlayingSeqs) do
            audio_stream_set_volume(stream, sequence_player_get_volume(player))
        end
        menuWasOpen = false
    end
end

---@param m MarioState
---@param incAct integer
function hooks.before_set_mario_action(m, incAct)

    if m.action == ACT_CAUGHT_IN_TAZ_TORNADO then
        vec3s_copy(m.angleVel, gVec3sZero())
        m.faceAngle.x = 0
        m.twirlYaw = 0
    end

    if not _G.charSelect.gCSPlayers[m.playerIndex].movesetToggle then return end

    local repData = CT_REPLACE_ACTS[_G.charSelect.character_get_current_number(m.playerIndex)]

    if repData then
        local param = 1
        if repData.param then
            param = repData.param(m, incAct)
        end

        if repData.acts[param] then
            if playerTable[m.playerIndex].blockCTActsTimer == 0 then
                return set_mario_action(m, repData.acts[param], 0)
            end
            return 1
        end
    end
end

---@param m MarioState
---@param o Object
---@param intType InteractionType
---@param interacted boolean
function hooks.on_interact(m, o, intType, interacted)

    if not _G.charSelect.gCSPlayers[m.playerIndex].movesetToggle then return end

    local repData = CT_REPLACE_ACTS[_G.charSelect.character_get_current_number(m.playerIndex)]

    if not repData or not repData.actsSet[m.action] then return end

    if intType == INTERACT_GRABBABLE and
    not interacted and
    o.oInteractionSubtype & INT_SUBTYPE_NOT_GRABBABLE == 0 and
    repData.canGrab(m) then
        m.interactObj = o
        m.input = m.input | INPUT_INTERACT_OBJ_GRABBABLE

        if o.oSyncID ~= 0 then
            network_send_object(o, true)
        end
    end
end

---@param idx integer
function hooks.on_nametags_render(idx)
    if idx == 0 or _G.charSelect.character_get_current_number(idx) ~= CT_BUGS then return end

    if states[idx].action == ACT_BUGS_MOVE_UNDERGROUND then
        return ''
    end
end

---@param player integer
---@param seqId SeqId
function hooks.on_seq_load(player, seqId)
    if not isLT64Char() then return end

    if curPlayingSeqs[player] then
        audio_stream_stop(curPlayingSeqs[player])
        curPlayingSeqs[player] = nil
    end

    local replaceInfo = STREAM_AS_SEQS[seqId]
    if replaceInfo then
        if replaceInfo.looping then
            if replaceInfo.loopStart and replaceInfo.loopEnd then
                audio_stream_set_loop_points(replaceInfo.audio, replaceInfo.loopStart, replaceInfo.loopEnd)
            end
            audio_stream_set_looping(replaceInfo.audio, true)
        end

        audio_stream_play(replaceInfo.audio, true, sequence_player_get_volume(player))
        curPlayingSeqs[player] = replaceInfo.audio
        return 0
    end
end

---@param soundId integer
---@param pos Vec3f
function hooks.on_play_sound(soundId, pos)

    if soundId == SOUND_MENU_THANK_YOU_PLAYING_MY_GAME then
        local clip = CT_THANKS_FOR_PLAYING_CLIPS[_G.charSelect.character_get_current_number()]

        if clip then
            audio_sample_play(clip, pos, 5)
            return 0
        end
    end
end

---@param o Object
function hooks.on_object_render(o)
    if obj_has_behavior_id(o, id_bhvBasketBall) ~= 0 and o.oAction == 0 then
        local m = states[getLocalFromGlobalIdx(o.oOwner)]

        o.oPosX = get_hand_foot_pos_x(m, 0) + 25 * sins(math.s16(m.faceAngle.y + 0x4000))
        o.oPosY = get_hand_foot_pos_y(m, 0)
        o.oPosZ = get_hand_foot_pos_z(m, 0) + 25 * coss(math.s16(m.faceAngle.y + 0x4000))

        m.marioObj.oPosY = m.marioObj.oPosY + 100
        
        local yaw, pitch = obj_angle_to_object(m.marioObj, o), obj_pitch_to_object(m.marioObj, o)
        o.oPosX = o.oPosX + 20 * sins(yaw) * coss(pitch)
        o.oPosY = o.oPosY - 30 * coss(yaw) * sins(pitch)
        o.oPosZ = o.oPosZ + 20 * coss(yaw) * coss(pitch)
        m.marioObj.oPosY = m.marioObj.oPosY - 100

        obj_set_gfx_pos_from_pos(o)
    end
end

function hooks.allow_menu_open()
    local noMenuActs = {
        [ACT_BUGS_LOLA_HOVER] = true,
        [ACT_BUGS_DIVE_POUND] = true,
        [ACT_BUGS_MOVE_UNDERGROUND] = true,
        [ACT_DAFFY_POUND] = true,
        [ACT_DAFFY_POUND_LAND] = true,
        [ACT_DAFFY_POUND_BOUNCE] = true,
        [ACT_DAFFY_MALLET_SWING] = true,
        [ACT_ELMER_SHOOT_SHOTGUN] = true,
        [ACT_ELMER_AIR_SHOOT_SHOTGUN] = true,
        [ACT_SYLVESTER_TWEETY_GLIDE] = true,
        [ACT_SYLVESTER_TWEETY_FIGHT] = true,
        [ACT_SYLVESTER_WALL_CRAWL] = true,
        [ACT_MARVIN_SHOOT_LASER] = true,
        [ACT_MARVIN_AIR_SHOOT_LASER] = true,
        [ACT_MARVIN_GRAB_TNT] = true,
        [ACT_TAZ_TORNADO_START] = true,
        [ACT_TAZ_TORNADO_ATTACK] = true,
        [ACT_CAUGHT_IN_TAZ_TORNADO] = true,
        [ACT_FOGHORN_SLAP_CHARGE] = true,
        [ACT_FOGHORN_SLAP_RELEASE] = true,
        [ACT_SLAPPED_BY_FOGHORN] = true,
        [ACT_WILE_AIR_WALK] = true,
        [ACT_WILE_ROCKET_EXPLODE] = true,
        [ACT_WILE_ROCKET_JUMP] = true
    }

    return not noMenuActs[states[0].action]
end

---@param prevChar integer
---@param curChar integer
function hooks.on_character_change(prevChar, curChar)
    if not isLT64Char() then
        for player, stream in pairs(curPlayingSeqs) do
            local seqId = nil
            if stream then
                for ogSeqId, replaceInfo in pairs(STREAM_AS_SEQS) do
                    if replaceInfo.audio == stream then
                        seqId = ogSeqId
                        break
                    end
                end
                audio_stream_stop(stream)
            end

            if seqId then
                play_music(player, seqId, 0)
            end
        end
    elseif not LT_64_CHARS[prevChar] then
        local curSeqId = get_current_background_music()
        if STREAM_AS_SEQS[curSeqId] then
            play_music(SEQ_PLAYER_LEVEL, curSeqId, 0)
        end
    end
end

local JUMP_ACTIONS = {
    [ACT_JUMP] = true,
    [ACT_HOLD_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_LONG_JUMP] = true,
    [ACT_STEEP_JUMP] = true,
    [ACT_SIDE_FLIP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_BURNING_JUMP] = true,
    [ACT_WATER_JUMP] = true,
    [ACT_HOLD_WATER_JUMP] = true,
    [ACT_METAL_WATER_JUMP] = true,
    [ACT_TOP_OF_POLE_JUMP] = true,
    [ACT_SPECIAL_TRIPLE_JUMP] = true,
    [ACT_RIDING_SHELL_JUMP] = true,
    [ACT_WALL_KICK_AIR] = true
}

---@param m MarioState
function hooks.bugs_lola_on_set_mario_action(m)
    if JUMP_ACTIONS[m.action] then
        m.vel.y = m.vel.y * ternary(_G.charSelect.character_get_current_number(m.playerIndex) == CT_BUGS, 1.3, 1.2)
    end
end

---@param m MarioState
function hooks.daffy_before_phys_step(m)
    if m.action & ACT_FLAG_SWIMMING ~= 0 and
    m.action & ACT_FLAG_INVULNERABLE == 0 and
    m.action ~= ACT_WATER_PLUNGE then
        vec3f_mul(m.vel, 3)
    end
end

---@param m MarioState
function hooks.sylvester_mario_update(m)

    if _G.charSelect.character_get_current_number(m.playerIndex) ~= CT_SYLVESTER or
    is_player_active(m) == 0 or
    m.flags & MARIO_CAP_ON_HEAD == 0 then
        return
    end

    local tweety = obj_get_first_with_behavior_id(id_bhvTweety)
    while tweety do
        if tweety.globalPlayerIndex == m.marioObj.globalPlayerIndex then
            break
        end

        tweety = obj_get_next_with_same_behavior_id(tweety)
    end

    if tweety then return end

    spawn_non_sync_object(id_bhvTweety, E_MODEL_TWEETY, m.pos.x, m.pos.y + 150, m.pos.z, function (o)
        o.globalPlayerIndex = m.marioObj.globalPlayerIndex
    end)
end

---@param m MarioState
function hooks.marvin_mario_update(m)
    if m.controller.buttonPressed == X_BUTTON and
    playerTable[m.playerIndex].blockCTActsTimer == 0 and
    m.floorHeight == m.pos.y and
    m.action & (PREVENT_ACT_FLAGS) == 0 and
    not PREVENT_ACT_GROUPS[m.action & ACT_GROUP_MASK] and
    m.action ~= ACT_MARVIN_SHOOT_LASER and m.action ~= ACT_MARVIN_GRAB_TNT then
        set_mario_action(m, ACT_MARVIN_GRAB_TNT, 0)
    end
end

local LAND_ACTIONS = {
    [ACT_JUMP_LAND] = true,
    [ACT_HOLD_JUMP_LAND] = true,
    [ACT_LONG_JUMP_LAND] = true,
    [ACT_DOUBLE_JUMP_LAND] = true,
    [ACT_TRIPLE_JUMP_LAND] = true,
    [ACT_LAVA_BOOST_LAND] = true,
    [ACT_DEATH_EXIT_LAND] = true,
    [ACT_AIR_THROW_LAND] = true,
    [ACT_BACKFLIP_LAND] = true,
    [ACT_FREEFALL_LAND] = true,
    [ACT_HOLD_FREEFALL_LAND] = true,
    [ACT_METAL_WATER_FALL_LAND] = true,
    [ACT_METAL_WATER_JUMP_LAND] = true,
    [ACT_WATER_JUMP] = true,
    [ACT_HOLD_WATER_JUMP] = true,
    [ACT_TOP_OF_POLE_JUMP] = true,
    [ACT_SIDE_FLIP_LAND] = true,
    [ACT_QUICKSAND_JUMP_LAND] = true,
    [ACT_SOFT_BONK] = true,
    [ACT_GROUND_BONK] = true,
    [ACT_BACKWARD_GROUND_KB] = true,
    [ACT_HARD_BACKWARD_GROUND_KB] = true,
    [ACT_SOFT_FORWARD_GROUND_KB] = true
}

---@param m MarioState
function hooks.lola_before_phys_step(m)
    if m.action & (ACT_FLAG_INVULNERABLE | ACT_FLAG_THROWING | ACT_FLAG_BUTT_OR_STOMACH_SLIDE) == 0 and
    m.action & ACT_GROUP_MASK ~= ACT_GROUP_CUTSCENE and not LAND_ACTIONS[m.action] then
        m.vel.x = m.vel.x * 1.5
        m.vel.z = m.vel.z * 1.5
    end
end

---@param m MarioState
function hooks.sam_mario_update(m)
    if m.action == ACT_GROUND_POUND and m.controller.buttonPressed & B_BUTTON ~= 0 then
        return set_mario_action(m, ACT_SAM_AIR_SHOOT_PISTOL, 0)
    end
end

return hooks